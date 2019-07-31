% data1 = rand(1,20)./2;      %# Sample data set 1
% data2 = 0.3+rand(1,20)./2;  %# Sample data set 2
hAxes = axes('NextPlot','add',...           %# Add subsequent plots to the axes,
             'DataAspectRatio',[1 1 1],...  %#   match the scaling of each axis,
             'XLim',[0 1],...               %#   set the x axis limit,
             'YLim',[0 eps],...             %#   set the y axis limit (tiny!),
             'Color','none');               %#   and don't use a background color
         xlabel ("Cell Area")
plot(data1,0,'r*','MarkerSize',10);  %# Plot data set 1
plot(data2,0,'b.','MarkerSize',10);  %# Plot data set 2