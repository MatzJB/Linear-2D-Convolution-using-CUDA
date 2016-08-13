/*
Matz JB 2012
 This code peforms the convolution between two (MxNx1) matrices
 Required memory: 6 units

Install with: CUDA_Conv_INSTALL.m
*/
 

#include <mex.h>
#include "errCodes.h"
#include "MCConv.h"
#include <math.h>

void myExitFcn()
{
  mexPrintf("MEX-file is being unloaded\n");
}


void mexFunction( int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[] )
{

int M, N;

 if (nlhs!=1)
    mexErrMsgTxt("The number of outputs should be 1\n");


  if(nrhs==0)
    {
      mexPrintf("Error: Provide with input data please\n");
      return;
    }

	
  if(nrhs!=2)
    {
      mexPrintf("Error: Provide two matrices please\n");
      return;
    }

	
  float * indata1;
  float * indata2;
  float * outdata;
int tmpM, tmpN;


  tmpM = (int)mxGetM(prhs[0]);
  tmpN = (int)mxGetN(prhs[0]);
  
  M = (int)mxGetM(prhs[1]);
  N = (int)mxGetN(prhs[1]);
  
  if (M!=tmpM)
    mexErrMsgTxt("The number of rows in the inputs must match.\n");

	if (N!=tmpN)
    mexErrMsgTxt("The number of columns in the inputs must match.\n");

  if (nrhs != 2) 
    mexErrMsgTxt("Hello, I want 2 inputs.\n");
  else if (nlhs != 1)
    mexErrMsgTxt("I want a single output.\n");
  
  indata1 = (float*) mxGetPr(prhs[0]);
  indata2 = (float*) mxGetPr(prhs[1]);

  plhs[0] = mxCreateNumericMatrix(M, N, mxSINGLE_CLASS, mxCOMPLEX);
  outdata = (float*) mxGetPr(plhs[0]); //casting necessary
	
	int err;

//Launching kernel
  Convolution(indata1, indata2, outdata, M, N, &err);
	
	mexprintError(err); //if an error occurs, we pass it on to Matlab
  
  if(mexAtExit(myExitFcn))
    {
      mexPrintf("Error unloading function!\n");
    }
  	
}

