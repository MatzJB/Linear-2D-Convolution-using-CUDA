%Matz JB Sept 2012
%Compiles the CUDA routine named <argument>.cu and <argument>.cpp

function install_CUDA_routine(routine)

disp(['Installing... ',routine])
%Add *your* paths
%addpath('C:\Users\Matz\Dropbox\Dropbox\Xjobb\Matlab\Matlab\proof\')
%utilpath = 'C:\Users\Matz\Dropbox\Dropbox\Xjobb\Matlab\Matlab\proof\'; 
utilpath = '.';

VS = findPath('Visual');    

if ~isa(routine, 'char')
    error('Provided routine name is not a string.')
end

cudafile   = [routine, '.cu'];

peripheral = 'errCodes.cpp';%used by CConv and CUFFTplanmem

if ~exist(cudafile, 'file')
    str = ['CUDA file ''', cudafile, ''' was not found.'];
    error(str);
end

mexfile     = routine;
mexfile_tmp = [mexfile, '.c'];

if ~exist(mexfile_tmp, 'file')
    str         = ['Mex function file ''', mexfile_tmp, ''' was not found.'];
    mexfile_tmp = [mexfile, '.cpp'];
    
    if ~exist(mexfile_tmp, 'file')
        str = ['Mex function file ''', mexfile_tmp, ''' nor ''', [mexfile, '.c'],''' was found.'];
        error(str);
    end
end

mexfile = mexfile_tmp;

if ~exist(peripheral, 'file')
    str = ['Peripheral file ''', peripheral, ''' was not found.'];
    error(str)
end

mexfile  = [mexfile,' ', peripheral];
objfile  = [routine, '_cu.o'];


disp(['Clearing: mex, functions...'])
clear mex
clear functions

cudart = ' -lcuda -lcudart -lcufft';

%VS     = '"C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\lib"';
str    = ['!del ', objfile];

%errors in nvcc is not propagated to error exception, we delete the object
%file to "catch" this
disp(['Deleting objfile...'])
try
%eval(str)
catch exception
end
    
cudafile

try
    str = ['!nvcc -c ', cudafile, ' -o ', objfile, '  -arch compute_20 -I"',...
        getenv('CUDA_INC_PATH'), '" -L"', VS, '" -L"', getenv('CUDA_LIB_PATH'),...
        '"', cudart];
    
    %fprintf(1,' executing: %s\n', str)
    
    eval(str);
catch exception
    warning('Compilation stage: failed.')
    disp(' ')
    rethrow(exception)
    return
end

try
    str = ['mex ', mexfile, ' ', objfile,' -I"', utilpath , '" -L"',...
        getenv('CUDA_LIB_PATH'), '" -lcudart -lcufft'];
    %fprintf(1,' executing: %s\n', str)
    
    eval(str);
catch exception
    warning('Compilation stage: failed.')
    disp(' ')
    rethrow(exception)
end

disp('Compilation stage: passed.')
disp(' ')
disp(['    The routine ''', routine, ''' was installed successfully.'] )
disp(' ')
