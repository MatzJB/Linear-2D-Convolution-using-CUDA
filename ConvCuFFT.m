%ConvCuFFT (2 Dimensional) Linear Convolution.
%   C = ConvCuFFT(I, K) returns the linear convolution between I and K.
%   The routine is executed on the GPU (via Mex and CUDA routines).

function z = ConvCuFFT(g, h)

%add padding
[r,c,~] = size(g);

g(2*r, 2*c, :)  = 0;
h(2*r, 2*c)     = 0;

z = ConvCuFFTX(g, h, false, false, true);

%break out result
z = z(r/2:r/2+r, c/2:c/2+c, :);
end
