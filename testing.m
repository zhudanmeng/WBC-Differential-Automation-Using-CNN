Files=dir('[N] Collection 1');
idxY = [];
for k=3:length(Files)
rgbImage = imread(strcat('[N] Collection 1\', Files(k).name));
idxY = [idxY, mean(nonzeros(rgbImage(:)))];
end
% x = mean([mean(nonzeros(rgbImage1(:))),mean(nonzeros(rgbImage2(:))),mean(nonzeros(rgbImage3(:)))...
% ,mean(nonzeros(rgbImage4(:))),mean(nonzeros(rgbImage5(:))),mean(nonzeros(rgbImage6(:)))...
%     ,mean(nonzeros(rgbImage8(:))),mean(nonzeros(rgbImage9(:))),mean(nonzeros(rgbImage7(:)))]);

