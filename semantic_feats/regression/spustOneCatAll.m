clear ; close all; clc


ar=argv();
categ = ar{1};
type=ar{2};

rand('seed', 5);

fprintf('Nacitam...\n');
%pause;
%load('ex3data1.mat');
X=load('../ML_tables/features');

y=load(strcat('../ML_tables/is', categ));


fprintf('Nacteno.\n');
%pause;
%maxxA = round(size(y)(1)*8/10);
maxxB = round(size(y)(1)*9/10);

rrr = randperm(size(X,1));
XShuff = X(rrr,:);
yShuff = y(rrr,:);




XTrain = XShuff(1:maxxB,:);
yTrain = yShuff(1:maxxB,:);
XTest = XShuff(maxxB:end,:);
yTest = yShuff(maxxB:end,:);
clear X;
clear y;
clear rrr;

inp = load(strcat('../results/ML_lambda_',type,'_', categ));
lambda =    inp(1)
tolerance  =inp(2)

%lambda = 2;
thetas = one(XTrain, yTrain, lambda, 50);
fprintf('Program paused. Press enter to continue.\n');
%pause;


%% ================ Part 3: Predict for One-Vs-All ================
pred = predictOne(thetas, XTest, tolerance);


TP = 0.0 + sum(pred&yTest);
FP = 0.0 + sum(pred&(!yTest));
FN = 0.0 + sum((!pred)&yTest);
TN = 0.0 + sum((!pred)&(!yTest));

toprint = [TP FP FN TN]

save(strcat('../results/ML_results_',type,'_',categ), 'toprint');
