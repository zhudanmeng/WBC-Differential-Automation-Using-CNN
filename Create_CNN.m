%% Initialization

%Clean memory and command window
clear,clc,close all;
run([cd,'\tools\matlab\vl_setupnn.m']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Creat_db = false;
train_ratio = 0.7;     % Ratio of data used for training
image_size  = 64;      % Side length of input images
pad = [0,0,0,0];
gray = false; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CNN architecture parameters
a  = 7;    % Side length of filters in first convolution
N1 = 15;   % Number of filters in first convolution
r  = 2;    % Side length of window in first pooling
a2 = 3;    % Side length of filters in second convolution
N2 = 20;   % Number of filters in second convolution
H = 100;   % Number of neurons in hidden layer

% Training parameters
opts.batchSize = 256 ;
opts.numSubBatches = 1 ;
opts.epochSize = inf;
opts.prefetch = false ;
opts.numEpochs = 40;
opts.learningRate = 0.01 ;
opts.weightDecay = 0.0005 ; 
opts.momentum = 0.9 ;
opts.randomSeed = 0 ;
opts.conserveMemory = true ;
opts.plotDiagnostics = false ;
opts.plotStatistics = true;
opts.gpus = [];

% true to normalize batch, false to not normalize batch.
BatchNorm   = true;      
% true = start from last checkpoint
% false = start from begining
opts.continue = true;
% postEpochFn(net,params,state) called after each epoch;
% can return a new learning rate, 0 to stop, [] for no change
opts.postEpochFn = []; 
% Empty array means use the default SGD solver
opts.solver = [] ; 

%% Reading the database
% the system data type
dataType = 'single'; 
if Creat_db
    dataDir = uigetdir(cd,'Select folder containing data');
    imdb = getImdb(dataDir,[image_size,image_size],...
        train_ratio,dataType,pad,gray);
else
     load('imdb.mat');
end
num_class = length(imdb.meta.classes);
if gray
    ch = 1;
else
    ch = 3;
end

%% Building the CNN architecture
F=1/100 ;
% calculating cnn parameters
f  = image_size-a+1;
p  = floor(f/r);
f2 = p-a2+1;
r2 = f2;
% building cnn
net.layers = {}; % initializing a network
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{F*randn(a,a,ch,N1, dataType),...
                           zeros(1, N1, dataType)}}, ...
                           'stride', 1, ...
                           'pad', 0);
net.layers{end+1} = struct('type', 'relu');
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'max', ...
                           'pool', [r r], ...
                           'stride', r, ...
                           'pad', 0);
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{F*randn(a2,a2,N1,N2, dataType),...
                           zeros(1, N2, dataType)}}, ...
                           'stride', 1, ...
                           'pad', 0);
net.layers{end+1} = struct('type', 'relu');
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'max', ...
                           'pool', [r2 r2], ...
                           'stride', r2, ...
                           'pad', 0);
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{F*randn(1,1,N2,H, dataType),...
                           zeros(1,H,dataType)}}, ...
                           'stride', 1, ...
                           'pad', 0) ;
net.layers{end+1} = struct('type', 'relu');
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{F*randn(1,1,H,num_class, dataType),...
                           zeros(1,num_class,dataType)}}, ...
                           'stride', 1, ...
                           'pad', 0) ;
net.layers{end+1} = struct('type', 'softmaxloss') ;

% optionally insert batch normalization
if BatchNorm
  net = insertBnorm(net, 1) ;
  net = insertBnorm(net, 5) ;
end

% Meta parameters
tmp = size(imdb.images.data);
net.meta.inputSize = tmp(1:3);
net.meta.trainOpts.learningRate = opts.learningRate ;
net.meta.trainOpts.numEpochs = opts.numEpochs ;
net.meta.trainOpts.batchSize = opts.batchSize ;
net.meta.averageImage = imdb.images.data_mean;
net.meta.classes = imdb.meta.classes;

% Fill in any values we didn't specify explicitly
net = vl_simplenn_tidy(net) ;

%% Training the network
tic;
[net, stats] = cnn_train(net, imdb, @(imdb, batch) getBatch(imdb, batch), ...
  'train', find(imdb.images.set == 1),...
  'val', find(imdb.images.set == 2),...
  'expDir', 'Checkpoint',...
   opts);

%% Saving best trained network
obj = zeros(opts.numEpochs,1);
for i=1:opts.numEpochs
    obj(i) = stats.val(i).objective;
end
[~,best_epoch] = min(obj);
load([cd,'\Checkpoint\net-epoch-',num2str(best_epoch),'.mat']);
net.layers(end)=[];
save('net','net');
disp(' ')
disp('==================================')
disp('Done training the network')
toc
disp('==================================')
disp(' ');

%% Analysing trained network

% Showing filters
for i=1:length(net.layers)
    if strcmp(net.layers{i}.type,'conv')
        figure(),vl_tshow(net.layers{i}.weights{1})
        colormap gray
        title(['Shape of filters: Layer(',num2str(i),')'])
    end
end

% Calculating precision
idx = imdb.images.set==2;
Xtest = imdb.images.data(:,:,:,idx);
res = vl_simplenn(net,Xtest);
res = squeeze(res(end).x);
res = softmax(res);
Exact = zeros(size(res));
tmp = imdb.images.labels(idx);
for i=1:length(tmp)
    Exact(tmp(i),i) = 1;
end
% Plotting roc
plotroc(Exact,res);
% showing precision
[~, res] = max(res);
Accuracy = 100*sum(res == tmp)/sum(idx);
disp(['Accuracy = ',num2str(Accuracy),'%'])