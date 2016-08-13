//Matz JB Aug 2012
//This code only return the memory free on the device

#include <stdio.h>
#include <math.h> 
#include <cufft.h>

extern "C" void CUDAavailablemem(int *total, int *free)
{
	size_t memfree;
	size_t memtotal;

	cudaMemGetInfo(&memfree, &memtotal);
	*total = memtotal/pow(2.0,20);
	*free = memfree/pow(2.0,20);
}
