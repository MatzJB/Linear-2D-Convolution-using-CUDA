%CUDA (2 Dimensional) Convolution.
%   C = ConvCuFFTX(I, K) returns the cyclical convolution between I and K.
%   The routine is executed on the GPU (via Mex and CUDA routines).
%
% This function works as a wrapper to the mex module CConv.mexw64.
% If the CUFFT plan overflows memory, CUDA will crash. Therefore this
% function will test the available memory on the GPU, estimate the amount
% of memory the computation it will require and return an error message if
% the computation will likely overflow the available memory.
%
% Note:
% Attempting to convolve A and B where size(A) <= [1,1] will result in a
% compromised CUDA context. To keep the context intact, we choose to return an
% error message and terminate the computation instead.
% The code frequently reference the results in the report
% "Study of Convolution Algorithms using CPU and Graphics Hardware".

% Note: To try to fit as much data on the GPU as possible is generally not a
% good idea. The speedup provided by the GPU in these circumstances are
% modest and should be avoided. The function return a warning if this happens.

% g is a padded 3-channel image.
% h is a full 1-channel kernel.


function z = ConvCuFFTX(g, h, verbose, warmup, safe)

if ~exist('MCConv', 'file')
    error('MCConv is not in the path.')
end


if not(isa(g, 'single')) || not(isa(h, 'single'))
    error('Both input arguments must be single precision.')
end


[gy, gx, gz] = size(g);
[hy, hx]     = size(h);

if not( gz==3 )
    error('Image must consist of 3 channels (RGB).')
end

if not( gy==hy )
    fprintf(1, 'Number of rows (%d) in the image differ from number of rows in the kernel (%d)\n.', gy, hy);
    error('Bailing out.')
end

if not( gx==hx )
    fprintf(1, 'Number of columns (%d) in the image differ from the number of columns in the kernel (%d)\n.', gx, hx);
    error('Bailing out.')
end


if verbose && safe
    disp('Using safe mode')
end


if warmup
    
    if verbose
        tic
    end
    
    N   = 2;
    A   = rand(N, N, 'single');
    tmp = MCConv(A, A);
    
    if verbose
        fprintf('  Warmup took: %d s.\n', toc)
    end
end


if gy<=2 || gx<=2
    error('The input data is too small. The computation was terminated.')
end

tmp = CUDAavailablemem;
availablemem = tmp(1);

delta    = 125; %5.2.5 adding some grace, especially important for non-square sizes
gy_new=gy;
gx_new=gx;
%We know the plan will fit in memory, since we use extra padding
mem_plan = CUFFTplanmem(single([gy_new, gx_new]));

%Estimating plan size using real values and estimated "grace" memory
unit             = (gy_new + delta)*(gx_new + delta)*4/2^20;
units_with_plan  = mem_plan(1) + 4*unit;

if safe
    units_safe   = 6*unit; %provides a "grace memory", will work for all cases
else
    units_safe   = units_with_plan; %should work for most cases
end

units_max        = max([units_with_plan, units_safe]); %to make sure the amount of memory is enough

does_not_fit     = units_max > availablemem;

if does_not_fit
    fprintf(1, 'The computation requires a minimum of (using accurate plan) %d MB. Total memory available: %d MB\n', units_with_plan, availablemem);
    fprintf(1, 'Expected allocated memory: %d MB\n', units_max);
    error('*The computations will not fit on the GPU, exiting.')
end

%We are trying to use all available memory on the GPU. This might result in
%a poor speedup
if verbose
    
    if units_max > 0.85*availablemem %* According to Section 5.5
        fprintf(1, '   The computation will cause the GPU to almost run out of memory.\n');
        fprintf(1, '   The data will allocate %d%% of available memory (estimated).\n', ceil(100*units_max/availablemem));
        %warning('The Computation will cause the GPU to almost run out of memory')
        fprintf(1, '   This will affect the performance negatively.\n');
    end
end


try

    z(:, :, 1) = MCConv(g(:, :, 1), h);
    memdiff(availablemem, 1, unit, verbose);
    z(:, :, 2) = MCConv(g(:, :, 2), h);
    memdiff(availablemem, 2, unit, verbose);
    z(:, :, 3) = MCConv(g(:, :, 3), h);
    
catch exception
    
    if verbose
        fprintf(1, 'CUDA Convolution execution returned an error.\n');
        fprintf(1, 'The Matlab session may be compromised, if subsequent runs returns an error restart Matlab and try again.\n');
    end
    rethrow(exception)
end

end



function memdiff(availablemem_pre, run, unit, verbose)

tmp = CUDAavailablemem;
availablemem_post = tmp(1);

if availablemem_pre > availablemem_post
    
    if 6*unit < availablemem_post
        
        if verbose
            fprintf(1, '   Computation freed memory, total memory available is %d MB.\n', availablemem_pre);
            fprintf(1, '   The total memory available was %d MB (call %d).\n', availablemem_post, run);
            fprintf(1, '   However, the data to complete the computation will still fit.\n');
        end
    else
        error('Available memory is not sufficient, bailing out.')
    end
end

end
