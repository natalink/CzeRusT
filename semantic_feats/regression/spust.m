clear ; close all; clc

%load('ex3data1.mat');
X=load('features');
y=load('categories');

max = round(size(y)(1)*9/10);

rrr = randperm(size(X,1));
XShuff = X(rrr,:);
yShuff = y(rrr,:);



XTrain = XShuff(1:max,:);
yTrain = yShuff(1:max,:);

num_labels = size(unique(y));%predpokladam, ze jsou od 1 do num_labels

lambda = 0.1;
[all_theta] = oneVsAll(XTrain, yTrain, num_labels, lambda);

fprintf('Program paused. Press enter to continue.\n');
pause;



%% ================ Part 3: Predict for One-Vs-All ================
%  After ...

XTest = XShuff(max:end,:);
yTest = yShuff(max:end,:);

pred = predictOneVsAll(all_theta, XTest);

fprintf('\nTesting Set Accuracy: %f\n', mean(double(pred == yTest)) * 100);

pred = predictOneVsAll(all_theta, XTrain);

fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred == yTrain)) * 100);

