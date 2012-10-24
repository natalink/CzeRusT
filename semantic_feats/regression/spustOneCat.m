clear ; close all; clc

fprintf('Nacitam...\n');
pause;
%load('ex3data1.mat');
X=load('features');
y=load('categories');

fprintf('Nacteno.\n');
pause;
maxx = round(size(y)(1)*9/10);

rrr = randperm(size(X,1));
XShuff = X(rrr,:);
yShuff = y(rrr,:);



XTrain = XShuff(1:maxx,:);
yTrain = yShuff(1:maxx,:);
XTest = XShuff(maxx:end,:);
yTest = yShuff(maxx:end,:);
clear X;
clear y;
clear XShuff;
clear yShuff;
clear rrr;

lambda = 0.1;
thetas = one(XTrain, yTrain, lambda, 50);

fprintf('Program paused. Press enter to continue.\n');
pause;



%% ================ Part 3: Predict for One-Vs-All ================
%  After ...


pred = predictOne(thetas, XTest);

TP = 0.0+ sum(pred&yTest);
precision = TP/sum(pred);
recall = TP/sum(yTest);

precision
recall

fprintf('\nTesting Set Accuracy: %f\n', mean(double(pred == yTest)) * 100);

%pred = predictOne(thetas, XTrain);

%fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred == yTrain)) * 100);

