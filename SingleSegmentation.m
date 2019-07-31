Files=dir('[N] Collection 1');
for k=3:length(Files)

he = imread(strcat('[N] Collection 1\', Files(k).name));
% imshow(he)
lab_he = rgb2lab(he);

ab = lab_he(:,:,2:3);
ab = im2single(ab);
nColors = 3;
% repeat the clustering 3 times to avoid local minima
pixel_labels = imsegkmeans(ab,nColors,'NumAttempts',3);

% imshow(pixel_labels,[])
% title('Image Labeled by Cluster Index');
mask1 = pixel_labels==1;
BW2 = bwareaopen(mask1,400);
cluster1 = he .* uint8(BW2);

index1= abs(mean(nonzeros(cluster1))-153.2248);

mask1 = pixel_labels==2;
BW2 = bwareaopen(mask1,400);
cluster1 = he .* uint8(BW2);

index2= abs(mean(nonzeros(cluster1))-153.2248);

mask1 = pixel_labels==3;
BW2 = bwareaopen(mask1,400);
cluster1 = he .* uint8(BW2);

index3= abs(mean(nonzeros(cluster1))-153.2248);

[val,correctIdx] = min ([index1 index2 index3]);

%%CHANGED TO 3 FOR EXPERIMENTAL PURPOSES, CHANGE BACK TO "correctIdx for old script
mask1 = pixel_labels==correctIdx;
BW2 = bwareaopen(mask1,400);

[row, col] = find(BW2);
if min(row)-20 >= 1
    pointA = min(row)-20;
else
    pointA = 1;
end

if max(row)+30 <= size(BW2, 1)
    pointB = max(row)+30;
else
    pointB = size(BW2, 1);
end
  
if min(col)-30 >= 1
    pointC = min(col)-30;
else
    pointC = 1;
end

if max(col)+30 <= size(BW2, 2)
    pointD = max(col)+30;
else
    pointD = size(BW2, 2);
end

BW2((pointA):pointB,pointC:pointD) = 1;
cluster1 = he .* uint8(BW2);





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
%figure
for i=1:n
    %imshow(ObjCell{i})
%     if (size(ObjCell{i},1) <= 280 && size(ObjCell{i},2) <= 200)
        imwrite(ObjCell{i}, strcat ('rbcImages/rbcI', num2str(n), 'Image', num2str(k), '.png'))
%     end
end
disp(strcat('progress: ', num2str(k*100/length(Files)), '%'))
end
