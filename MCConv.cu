
//Matz JB June 2012

//This code performs the convolution between two images
//IFFT( FFT2(A).*FFT2(B) ) where A:(MxN), B:(MxN)
//Memory requirement: 6 units

#include <stdio.h>
#include <math.h> 
#include <cufft.h>
#include "errCodes.h" 
//contains the hidden error message to mexprint, because we cannot print from the kernel

#define MAX_THREADS 1024 //the maximum number of threads for this GPU, change as appropriate


void sync()
{
cudaThreadSynchronize();
}

void cudaRelease(void *ptr) 
{
  if ( ptr != NULL ) 
    cudaFree(ptr); 
}

//http://gpgpu.org/wp/wp-content/uploads/2009/06/03-Toolkit.pdf
//Standard way of interlacing/weaving using the kernel
__global__ void weavecomplex (cufftComplex *c, float *a, int M, int N)
{
int idx = blockIdx.x*blockDim.x + threadIdx.x;
int idy = blockIdx.y*blockDim.y + threadIdx.y;

if(idx<M && idy<N)
{

int index = idx + idy*M;
c[index].x  = a[index];
c[index].y  = 0.f;

}
}


//We only need to unweave to real
__global__ void unweavecomplex2R (float *a, cufftComplex *c, int M, int N)
{

int idx = blockIdx.x*blockDim.x + threadIdx.x;
int idy = blockIdx.y*blockDim.y + threadIdx.y;
volatile float2 c2;//force vector load, increase memory coalescing

if(idx<M && idy<N)
	{
	int index = idx + idy*M;

	c2.x = c[index].x;
	c2.y = c[index].y;
	a[index] = c2.x;
	}
}


//Scaling is embedded in Hadamard product instead of inside the "weaving" functions
__global__ void hadamard3(cufftComplex * a, cufftComplex * b, int M, int N)
{
int idx = blockIdx.x*blockDim.x + threadIdx.x;
int idy = blockIdx.y*blockDim.y + threadIdx.y;
float scaling = 1.0f/sqrt(1.0f*M*N);
int index;
volatile float tmp;

	if(idx<M && idy<N)
	{
		index = idx + idy*M;
	
		a[index].x *= scaling;
		a[index].y *= scaling;
		b[index].x *= scaling;
		b[index].y *= scaling;

		tmp = a[index].x;
	
	//Naive complex multiplication, 2 addition, 4 multiplication
		a[index].x = tmp*b[index].x - a[index].y*b[index].y;
		a[index].y = tmp*b[index].y + a[index].y*b[index].x;
	}
}



//Convolves a and b and store the result in c.
extern "C" void Convolution(float *a, float *b, float *c, int M, int N, int *err)
{
	//Device data, only used on the device:
	//These declarations must be first since we risk to encounter errors for which we just go to "Error"
	cufftComplex *rhs_complex_d1 = NULL;
	cufftComplex *rhs_complex_d2 = NULL;

	float *a_d = NULL;
	
//Setting up Block and Grids for the thread mappping:
  int block_size_x = 32; //MAX_THREADS=1024, sqrt(1024) = 32
  int block_size_y = block_size_x;

  dim3 dimBlock(block_size_x, block_size_y, 1);
  dim3 dimGrid((M/dimBlock.x), (N/dimBlock.y));

  if (M % block_size_x !=0) 
	dimGrid.x+=1;

  if (N % block_size_y !=0) 
	dimGrid.y+=1;
    
  cufftHandle plan;
  *err = ERR_FAILSAFE;

//1 unit
	if( cudaMalloc((void **) &a_d, sizeof(float)*M*N) != cudaSuccess )
    {
		*err = ERR_MALLOC;
		goto Error;
    }
		
    if( cudaMemcpy(a_d, a, sizeof(float)*M*N, cudaMemcpyHostToDevice) != cudaSuccess )
    {
      *err = ERR_COPY;
      goto Error;
    }

		//3 units
	if( cudaMalloc((void **) &rhs_complex_d1, sizeof(cufftComplex)*M*N) != cudaSuccess )
    {
		*err = ERR_MALLOC;
		goto Error;
    }
	
	weavecomplex<<<dimGrid, dimBlock>>>(rhs_complex_d1, a_d, M, N);
	
	//5 units
	if( cudaMalloc((void **) &rhs_complex_d2, sizeof(cufftComplex)*M*N) != cudaSuccess )
    {
		*err = ERR_MALLOC;
		goto Error;
    }
	//sync();//better?

	//reuse a_d
	 if( cudaMemcpy(a_d, b, sizeof(float)*M*N, cudaMemcpyHostToDevice) != cudaSuccess )
    {
      *err = ERR_COPY;
      goto Error;
    }

	weavecomplex<<<dimGrid, dimBlock>>>(rhs_complex_d2, a_d, M, N);
	
	sync();//must wait for a_d to finish
	//4 units
	cudaRelease(a_d);

//At least 6 units
  if (cufftPlan2d(&plan, N, M, CUFFT_C2C) != CUFFT_SUCCESS)
    {
	  *err = ERR_PLAN;
	  goto Error;//added this 26/5   
    }

	if (cufftSetCompatibilityMode(plan, CUFFT_COMPATIBILITY_NATIVE) != CUFFT_SUCCESS)
	//if (cufftSetCompatibilityMode(plan, CUFFT_COMPATIBILITY_FFTW_PADDING) != CUFFT_SUCCESS)
	//if (cufftSetCompatibilityMode(plan, CUFFT_COMPATIBILITY_FFTW_ASYMMETRIC) != CUFFT_SUCCESS)
	//if (cufftSetCompatibilityMode(plan, CUFFT_COMPATIBILITY_FFTW_ALL) != CUFFT_SUCCESS)	
	{
		*err = ERR_COMPAT;
		goto Error;
    }
	

  if (cufftExecC2C(plan, rhs_complex_d1, rhs_complex_d1, CUFFT_FORWARD) != CUFFT_SUCCESS)
    {
		*err = ERR_FFT_FORWARD;
		goto Error;
    }

	//same plan to perform FFT on the other matrix
	if (cufftExecC2C(plan, rhs_complex_d2, rhs_complex_d2, CUFFT_FORWARD) != CUFFT_SUCCESS)
    {
		*err = ERR_FFT_FORWARD;
		goto Error;
    }

	hadamard3<<<dimGrid, dimBlock>>>(rhs_complex_d1, rhs_complex_d2, M, N);
//sync();

	if (cufftExecC2C(plan, rhs_complex_d1, rhs_complex_d1, CUFFT_INVERSE) != CUFFT_SUCCESS)
    {
		*err = ERR_FFT_INVERSE;
		
      goto Error;
    }
	
		cudaRelease(rhs_complex_d2);
	
		if( cudaMalloc((void **) &a_d, sizeof(float)*M*N) != cudaSuccess )
		{
		*err = ERR_MALLOC;
		goto Error;
		}
	
		unweavecomplex2R<<<dimGrid, dimBlock>>>(a_d, rhs_complex_d1, M, N);
	
	//Pick only real part and send back to host code	
	unweavecomplex2R<<<dimGrid, dimBlock>>>(a_d, rhs_complex_d1, M, N);
//sync(); //really?	
	cudaMemcpy(c, a_d, sizeof(float)*M*N, cudaMemcpyDeviceToHost);
		
	*err = ERR_OK;	//We reached this point thus everything went ok, otherwise we have ERR_FAILSAFESAFE, which should never happen

	
//Catch all error cases and clean up:	
	Error:
	
	cudaRelease(a_d);
	cudaRelease(rhs_complex_d1);
	
	cufftDestroy(plan);
		}
