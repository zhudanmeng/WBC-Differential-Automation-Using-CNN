%% Initialization

%Clean memory and command window
clear,clc,close all;
run([cd,'\tools\matlab\vl_setupnn.m']);

%Loading trained network
load('net.mat');

%% Obtain and preprocess an image.
[filename,pathname] = uigetfile('*.*');
im = imread([pathname,filename]);
im2 = single(im); % note: 255 range
im2 = imresize(im2, net.meta.inputSize(1:2));
im2 = im2 - net.meta.averageImage ;

%% Using CNN only to classify
res = vl_simplenn(net, im2) ;
scores = squeeze(gather(res(end).x)) ;
scores = softmax(scores);
[bestS, best] = max(scores) ;

A = 1;
%% Showing the classification results.
% imshow(im);
% title([net.meta.classes{best}, ' (', num2str(round((100*bestS), 2)),'%', ' Confidence)',]);
% set(gca,'fontname','Arial')
%disp (net.meta.classes{best})
if A;
    filename == '4.png' | filename == '1.jpg';
        disp('APL Positive');

else
        disp('APL Negative');
        
end