%Example code, just run after installing the routines

close all

%read test data, create kernel
g         = imread('Lena.png');
g         = single(g)./255; %convert to single precision, normalize to range [0,1]
[r, c, ~] = size(g);

%create a Gaussian R-by-C kernel matrix
h = fspecial('gaussian', [r,c], 18);
h = single(h);


%GPU version ******************************
tic
tmp = ConvCuFFT(g,h);
toc

figure
imagesc(tmp)
title('linear convolution (GPU)')

truesize

%CPU version ******************************
tic
g(2*r, 2*c,:) = 0;
h(2*r, 2*c)   = 0;
tmp2          = 0*g;

% The kernel is trivial in this example, but we calculate it three 
% times (we send R, G and B) because the GPU version does this. I will
% most probably change this behavior in the next commit.

fftK = fft2(h);
fftK = fft2(h);
fftK = fft2(h);

tmp2(:,:,1) = ifft2( fft2(g(:,:,1)).*fftK );
tmp2(:,:,2) = ifft2( fft2(g(:,:,2)).*fftK );
tmp2(:,:,3) = ifft2( fft2(g(:,:,3)).*fftK );
tmp2 = tmp2(r/2:r/2+r, c/2:c/2+c, :);
toc

figure

imagesc(tmp2)
truesize
title('linear convolution (CPU)')

