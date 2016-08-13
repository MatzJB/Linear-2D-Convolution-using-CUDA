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
 
4. Now cd to src and run 
`CUDA_Conv_INSTALL`


## Examples

To run the example/test.ms just cd to that directory and add to path and run. The example image file Lena.png is used.

![Lena](Examples/Lena.png)