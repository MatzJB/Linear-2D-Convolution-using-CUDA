%CConvCuFFT (2 Dimensional) Cyclical Convolution.
%   C = CConvCuFFT(I, K) returns the cyclical convolution between I and K.
%   The routine is executed on the GPU (via Mex and CUDA routines).

function z = CConvCuFFT(g, h)

z = ConvCuFFTX(g, h, false, false, true);

end
