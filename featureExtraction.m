I = imread('[N] Different Types WBC dataset\Mono1Image974.png');
I = rgb2gray(I);
figure;
imshow(I)
figure(2);
imhist(I);

I2 = imread('[N] Different Types WBC dataset\EO1Image3.png');
I2 = rgb2gray(I2);
figure(3);
imshow(I2)
figure(4);
imhist(I2);

I3 = imread('[N] Different Types WBC dataset\EO1Image358.png');
I3 = rgb2gray(I3);
figure(5);
imshow(I3)
figure(6);
imhist(I3);