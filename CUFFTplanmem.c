//Matz JB 2012

/*
Fetching the plan memory required for a given quad size (N^2)
OBS: The arguments must be singles!!

For instance (call from Matlab):
     tmp = CUFFTplanmem( single(size(A)) )
	 tmp(1) %contains planmem
	 tmp(2) %contains total memory (excluding plan memory)
*/
 
#include <mex.h>
#include "CUFFTplanmem.h"


void mexFunction( int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[] )
{

	int M, N;
	int m = 1, n = 1;
	int planmem  = 0;
	int totalmem = 0;
	float * input;
	float * outdata;

  if(nrhs==0)
    {
      mexPrintf("Error: Provide with input data please\n");
      return;
    }
	
	M = (int)mxGetM(prhs[0]);//length of vector
	N = (int)mxGetN(prhs[0]);
	
	input = (float*) mxGetPr(prhs[0]);

	if (N==2)
	{
		m = input[0];
		n = input[1];
	}
	else
	{
	m = input[0];
	n = m;
	}
	
	plhs[0] = mxCreateNumericMatrix(1, 2, mxSINGLE_CLASS, mxREAL);
	outdata = (float*) mxGetPr(plhs[0]); //must cast

	fetchplanmem(m, n, &planmem, &totalmem);
	
	outdata[0] = planmem;
	outdata[1] = totalmem;
}
