% Read the image and convert to gray-scale
I = imread('[N] Collection 1\001.jpg');
Igray = rgb2gray(I);

% Apply adaptive image threshold
T = adaptthresh(Igray,0.55);
BW = imbinarize(Igray,T);

% Calculate the average background RGB color
Imask = immultiply(I,repmat(BW,[1 1 3]));
Imask = reshape(Imask,[],3);
idx = any(Imask == 0,2);
bgColor = mean(Imask(~idx,:));

% Erase areas connected to image border and fill holes
BW = ~BW;
BW = imclearborder(BW);
BW = imfill(BW,'holes');

% Erase noise (small regions)
se = strel('disk',20);
BW = imerode(BW,se);
% Erase some regions where its average RGB is similar to the backgroud RGB
s = regionprops('table',BW,{'Area','PixelIdxList'});
I2 = reshape(I,[],3);
s.AvgRGB = zeros(height(s),1);
for kk = 1:height(s)
regColor = mean(I2(s.PixelIdxList{kk},:));
s.AvgRGB(kk,:) = norm(regColor - bgColor);
end
for kk = 1:height(s)
if s.AvgRGB(kk) <= 10 || s.Area(kk) < 200
  BW(s.PixelIdxList{kk}) = false;
end
end
% Apply watershed to separate overlapped cells
D = bwdist(~BW);
D = -D;
D = imgaussfilt(D, 10);
L = watershed(D);
L(~BW) = 0;
BW2 = L > 0;
% Visualize the result
label = label2rgb(L,'jet',[0.5 0.5 0.5]);
s = regionprops('table',BW2);
figure
imshowpair(I,label,'blend')
hold on
for kk = 1:height(s)
rectangle(...
  'Position',   s.BoundingBox(kk,:),...
  'EdgeColor',  'b')
text(s.BoundingBox(kk,1),s.BoundingBox(kk,2)-25,...
  num2str(kk),...
  'FontSize', 12)
end