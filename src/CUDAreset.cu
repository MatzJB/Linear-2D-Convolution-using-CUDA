//Matz JB June 2012
//This code only resets CUDA and sets up a new context

#include <stdio.h>
#include <math.h> 
#include <cufft.h>

extern "C" void CUDAreset()
{

for(int i=1; i<5; i++)
	if ( cudaDeviceReset() != cudaSuccess )
	;
	
}
