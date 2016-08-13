//Matz JB 2012

/*
This function is used to reset CUDA from Matlab
*/
 
#include <mex.h>
#include "CUDAreset.h"


void mexFunction( int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[] )
{
	CUDAreset();
}
