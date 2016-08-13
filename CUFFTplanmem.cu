//Matz JB June 2012
//This code only return the memory allocated by the plan

#include <stdio.h>
#include <math.h> 
#include <cufft.h>

extern "C" void fetchplanmem(int M, int N, int *planmemory, int *total)
{
	size_t memfree;
	size_t memtotal;
	size_t currentmem;

	cufftHandle plan;

	cudaMemGetInfo(&memfree, &memtotal);
	*total = memtotal/pow(2.0,20);
	
	cufftPlan2d(&plan, N, M, CUFFT_C2C);
    cudaMemGetInfo(&currentmem, &memtotal);
	
    *planmemory = (int) (memfree - currentmem)/pow(2.0, 20);
	
	cufftDestroy(plan);
}
