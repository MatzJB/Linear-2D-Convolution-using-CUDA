//Matz JB June 2012
#include "errCodes.h"
#include "mex.h"

void mexprintError(int x)
{
char * mess;
				
switch( x ) 
{
    case (enum ERROR_CODE) ERR_PLAN:
        mess = "CUFFT Plan creation was unsuccessful\n"; break;
	case (enum ERROR_CODE) ERR_FFT_FORWARD:
        mess = "Forward FFT2 could not be executed.\n"; break;
	case (enum ERROR_CODE) ERR_FFT_INVERSE:
        mess = "Inverse FFT2 could not be executed.\n"; break;
    case (enum ERROR_CODE) ERR_MALLOC:
        mess = "Call to CUDA Malloc was not successful.\n"; break;
	case (enum ERROR_CODE) ERR_COMPAT:
        mess = "Compatibility Mode was not set successfully.\n"; break;
	case (enum ERROR_CODE) ERR_COPY:
        mess = "Attempt to copy data was not successful.\n"; break;
	case (enum ERROR_CODE) ERR_FAILSAFE: //Should never happen
        mess = "An unknown error occured.\n"; break;
    break;
		
}

if (x>0)
   mexErrMsgIdAndTxt( "MATLAB:mexcallmatlab:CUFFT", mess);
}
