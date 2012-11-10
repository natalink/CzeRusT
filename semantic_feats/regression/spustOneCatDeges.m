clear ; close all; clc

lambda = 0.3;

rand('seed', 5);

fprintf('Nacitam...\n');
%pause;
%load('ex3data1.mat');
X=load('../ML_tables/features');
y=load('../ML_tables/isINT');


fprintf('Nacteno.\n');
%pause;
maxxA = round(size(y)(1)*8/10);
maxxB = round(size(y)(1)*9/10);

rrr = randperm(size(X,1));
XShuff = X(rrr,:);
yShuff = y(rrr,:);



XTrain = XShuff(1:maxxA,:);
yTrain = yShuff(1:maxxA,:);
XTest = XShuff(maxxA:maxxB,:);
yTest = yShuff(maxxA:maxxB,:);
clear X;
clear y;
clear XShuff;
clear yShuff;
clear rrr;

%lambda = 2;
thetas = one(XTrain, yTrain, lambda, 50);

fprintf('Program paused. Press enter to continue.\n');
%pause;



%% ================ Part 3: Predict for One-Vs-All ================
%  After ...


tolerance=0.5;
    pred = predictOne(thetas, XTest, tolerance);

    TP = 0.0+ sum(pred&yTest);
    precision = TP/sum(pred)
    recall = TP/sum(yTest)



    Fscore = 2*(precision*recall)/(precision+recall)


fprintf('\nTesting Set Accuracy: %f\n', mean(double(pred == yTest)) * 100);

pred = predictOne(thetas, XTrain, tolerance);

fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred == yTrain)) * 100);

