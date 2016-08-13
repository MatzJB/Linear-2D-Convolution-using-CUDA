%Matz JB Sept 2012
%CUDA_Conv_INSTALL compiles and tests the CUDA routine.
%Updated 20/10, added CUDA version to "readme"
%Updated 31/10, changed name from CConv to MCConv to avoid clash with
%Matlabs "cconv"

function CUDA_Conv_INSTALL()

%check paths
envvars  = {'CUDA_LIB_PATH','CUDA_INC_PATH'};
errstr   = 'Could not find environment variable ';

for i=1:length(envvars)
    if isempty(getenv(envvars{i}))
        error([errstr, envvars{i},'.']);
    end
end

VS = findPath('Visual');

if isempty(VS)
    error(['Could not find Visual Studio in path.']);
end

disp('The paths seems correct...')


install_CUDA_routine('MCConv')
install_CUDA_routine('CUFFTplanmem')
install_CUDA_routine('CUDAreset')
install_CUDA_routine('CUDAavailablemem')

N = 100;
A = rand(N, N, 'single');
B = rand(N, N, 'single');
C = rand(N, N, 'single');

try
    C = MCConv(A, B);
catch exception
    rethrow(exception)
end

disp('MCConv was executed sucessfully.')

%CUFFTplanmem and CUDAavailablemem does not have any error messaging. But
%these functions will never return an error. We only check if they were
%installed correctly.
disp('STARTING TEST PHASE')

try
    ans = CUFFTplanmem(single([1, 1]));
catch exception
  rethrow(exception)
end

disp('CUFFTplanmem was executed sucessfully.')

try
    ans = CUDAavailablemem();
catch exception
  rethrow(exception)
end

disp('CUDAavailablemem was executed sucessfully.')

try
    CUDAreset;
catch exception
  rethrow(exception)
end

disp('CUDAreset was executed sucessfully.')
disp(' ')


disp('CUDAreset was executed sucessfully.')
disp(' ')

disp('TEST PHASE FINISHED')


disp(' The installation of the CUDA routines are complete.')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This compilation only works for a specific CUDA version, we write this in the readme
%file below. As far as I (Matz) know, the Matlab version does not matter.
fileID = fopen('ReadMe.txt', 'wt');
version = getenv('CUDA_PATH');
tokens = strtok(version(end-1:-1:1), '\');

fprintf(fileID, '%s\n', ['This file was generated from CUDA_Conv_INSTALL at ', date, '.']); 
fprintf(fileID, '%s\n', 'CUDA_Conv_INSTALL and CUDA package was created Matz J.B. Sept 2012.');
fprintf(fileID, '%s\n\n\n', ['The CUDA routine passed tests using CUDA ', tokens(end:-1:1)]);

%fprintf(1, 'Make sure that the routines are compiled using CUDA %s.\n', tokens(end:-1:1));

fprintf(fileID, '%s\n', 'Compile the routines by calling ''CUDA_Conv_INSTALL''. See ''Study of'); 
fprintf(fileID, '%s\n', 'Convolution Algorithms using CPU and Graphics Hardware'' Section 8.2,'); 
fprintf(fileID, '%s\n', 'for details on how to properly setup the compiler environment.');


fclose(fileID);

disp(' ''ReadMe.txt'' was created.')
