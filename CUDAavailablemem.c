//Matz JB 2012

/*
This function is used to reset CUDA from Matlab
*/
 
#include <mex.h>
#include "CUDAavailablemem.h"


void mexFunction( int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[] )
{

	int free  = 0;
	int total = 0;
	
	float * outdata;
	
	plhs[0] = mxCreateNumericMatrix(1, 2, mxSINGLE_CLASS, mxREAL);
	outdata = (float*) mxGetPr(plhs[0]);

	CUDAavailablemem(&total, &free);
	outdata[0] = free;
	outdata[1] = total;
}
