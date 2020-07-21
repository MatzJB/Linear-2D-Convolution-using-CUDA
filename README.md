# Linear-2D-Convolution-using-CUDA
Linear 2D Convolution using nVidia CuFFT library calls via Mex interface.


## Installation

To install the routines you first need the Visual Studio redistributable in your path (for cl.exe). Example:

1. `C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\x86_amd64`

2. To run GPU code you need a nVidia graphics card and the CUDA SDK, see [developers.nvidia.com](https://developer.nvidia.com/cuda-downloads).

3. When installed the CUDA runtime, libraries and headers, point to them in the environment paths

 CUDA_LIB_PATH
 
 `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v7.5\lib\x64`
 
CUDA_INC_PATH

 `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v7.5\include`
 
 CUDA_PATH
 
 `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v7.5`
 
4. Now `cd` to `src` and run 
`CUDA_Conv_INSTALL`


## Examples

To run the example/test.ms just `cd` to that directory and add to path and run. The example image file Lena.png is used.



## Remarks

The code is the result of the my masters thesis in computer science ([link to report](http://matzjb.se/wp-content/uploads/media/reports/Matz%20JB%20-%20Master_Thesis_Study_of_Convolution_Algorithms_using_CPU_and_Graphics_Hardware%20-%202012_10_22.pdf)). I never implemented the convolution algorithm with all of the speed up tricks I had found during my research because of lack of time. I have since moved on, but there are a few ideas I would like to try out and some new algorithms I have worked on for 1D, 2D and even 3D convolution.

