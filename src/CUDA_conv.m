%CUDA (2 Dimensional) Convolution.
%   C = CUDA_Conv(I, K) returns the cyclical convolution between I and K.
%   The routine is executed on the GPU (via Mex and CUDA routines).
%
%This function works as a wrapper to the mex module CConv.mexw64.
%If the CUFFT plan overruns memory, CUDA will crash. Therefore this
%function will test the available memory on the GPU, estimate the amount
%of memory the computation will require and return an error message if
%the computation will overrun memory.
%
%In the event that required memory for a plan is larger than the total amount
%present on the system, the computation will bail, without first allocating
%the plan memory. Otherwise the plan memory is allocated, and the CUDA driver
%will crash.
%
%If the total required memory is smaller than the memory on the GPU, the
%function will call CUDAreset, which will reset the CUDA context in order
%to free up some memory.
%
%
%For optimal plan sizes, the user is referred to the report and Appendix
%figure.
%
%Known issues:
% Attempting to convolve A and B where size(A) <= [1,1] will result in a
% compromised CUDA context. To keep the context intact, we choose to return an
% error message and terminate the computation.
%
%
%   Written by Matz JB. Summer, 2012
% Removed "suggested input sizes" feature (5 Oct 2012)
% Added memory tests (25/10)
% This function is now obsolete (moved to ConvCuFFT3) (26/10)

function C = CUDA_conv(A, B)
C = CUDA_conv_(A, B, true, false);
end

function C = CUDA_conv_(A, B, safe, verbose)

%addpath('C:\Users\Matz\Dropbox\Dropbox\Xjobb\Matlab\Matlab\proof\cprintf')

C          = 0; %if it should fail
%delta      = 160;%not used because CUFFTplanmem safely reports upper bound as of CUDA 5.0
%col_orange = [1, 0.5, 0];

if all(size(A) <= [1, 1])
    error('The input data is too small. The computation was terminated.')
end

if not(safe) && verbose
    warning(' The code is currently not run in safe mode.')
    warning(' In case of a crash, the CUDA driver may force a restart of Matlab.')
    warning(' *Use with caution*')
end

if not(isa(A, 'single')) || not(isa(B, 'single'))
    error('Both input arguments must be single precision.')
end

if safe %safe mode, minimizes memory allocation error by estimating data allocated on the device
    
    tmp       = CUDAavailablemem();
    mem       = tmp(1);
    mem_total = tmp(2);
    [M,N]     = size(A);
    %unitsize = (M + delta)*(N + delta)*4/2^20; %modified
    unitsize  = M*N*4/2^20; %original, yielded unsuccessful plan creation for size: 6680, was fixed by checking return of CUFFTplanmem
    n_units   = 4;% "memsave" code: 4+plan memory units
    
    if n_units*unitsize + 2*unitsize > mem
        %if  n_units*M*N*4/2^20 + 2*unitsize > mem
        disp(size(A))
        warning([' The computation requires a minimum of ', num2str(2*unitsize + n_units*unitsize, 4),' MB. Total memory available: ', num2str(mem),' MB']);
        
        mem_req = n_units*unitsize + 2*unitsize;
        
        if mem_req < mem_total
            warning([' You need to free at least ', num2str(mem_req-mem),' MB to be able to finish the computation.'])
        end
        
        %CUDAreset();
        %cprintf('key', ['  Memory left on device was deemed insufficient.\n'])
        %error(' CUDA was reset. Try again.')
        
        error('The computation was terminated.')
    end
    
    tmp      = CUFFTplanmem(single(size(A)));
    mem_plan = tmp(1);
    %mem      = tmp(2);
    %plan memory was too large for some reason
    if numel(A) > 4000^2 && mem_plan == 0 %for a modest plan size, still returning 0 => error
        
        %TODO: change the error message to "The data fit but the plan was too large"
        %tips:
        warning([' The computation requires ', num2str(mem_plan + n_units*unitsize, 4),' MB. Total memory available: ', num2str(mem),' MB'])
        error('The plan was too large, bailing out.')
    end
    
    if verbose
        warning(' Using "safe mode".')
        warning([' The computation requires ', num2str(mem_plan + n_units*unitsize, 4),' MB. Total memory available: ', num2str(mem),' MB'])
        warning([' Image size: (', num2str(size(A, 1), 4), ' x ', num2str(size(A, 2),4), ')'])
    end
    
    if mem < mem_plan + n_units*unitsize
        %check memory before and after, and it it was enough
        CUDAreset();
        
        warning(['  Memory left on device was deemed insufficient.'])
        error(' Attempted to free up some memory, try again.')
    end
end

try
    C   = CConv(A, B);
catch exception % Something went wrong
    %disp('Something went wrong when calculating on CUDA')
    %disp(exception)
    %disp(' The CUDA context has been compromised. Restart Matlab.')
    rethrow(exception)
end

end