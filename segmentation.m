he = imread('[N] Collection 1\001.jpg');
% imshow(he)
lab_he = rgb2lab(he);

ab = lab_he(:,:,2:3);
ab = im2single(ab);
nColors = 3;
% repeat the clustering 3 times to avoid local minima
pixel_labels = imsegkmeans(ab,nColors,'NumAttempts',3);

% imshow(pixel_labels,[])
% title('Image Labeled by Cluster Index');

mask1 = pixel_labels==2;
BW2 = bwareaopen(mask1,400);
cluster1 = he .* uint8(BW2);

figure(3)
imshow(cluster1)
title('Objects in Cluster 1');
% CC = bwconncomp(BW2);
% disp ("Number of WBC: " + CC.NumObjects)

siz=size(BW2); % image dimensions
% Label the disconnected foreground regions (using 8 conned neighbourhood)
L=bwlabel(BW2,8);
% Get the bounding box around each object
bb=regionprops(L,'BoundingBox');
% Crop the individual objects and store them in a cell
n=max(L(:)); % number of objects
ObjCell=cell(n,1);
for i=1:n
      % Get the bb of the i-th object and offest by 2 pixels in all
      % directions
      bb_i=ceil(bb(i).BoundingBox);
      idx_x=[bb_i(1)-2 bb_i(1)+bb_i(3)+2];
      idx_y=[bb_i(2)-2 bb_i(2)+bb_i(4)+2];
      if idx_x(1)<1, idx_x(1)=1; end
      if idx_y(1)<1, idx_y(1)=1; end
      if idx_x(2)>siz(2), idx_x(2)=siz(2); end
      if idx_y(2)>siz(1), idx_y(2)=siz(1); end
      % Crop the object and write to ObjCell
      %cluster1=L==i;
      ObjCell{i}=cluster1(idx_y(1):idx_y(2),idx_x(1):idx_x(2), 1:3);
end
% Visualize the individual objects
figure
for i=1:n
    subplot(1,n,i)
    imshow(ObjCell{i})
end

% %Tried to add padding around the mask but couldn't figure it out
% mask2 = pixel_labels==2;
% cluster2 = he .* uint8(mask2);
% figure(4)
% imshow(cluster2)
% title('Objects in Cluster 2');

% mask3 = pixel_labels==3;
% cluster3 = he .* uint8(mask3);
% figure(5)
% imshow(cluster3)
% title('Objects in Cluster 3');

