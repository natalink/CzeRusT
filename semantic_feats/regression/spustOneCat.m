clear ; close all; clc

ar=argv();
lambdastr = ar{1};
lambda = str2num(lambdastr);
categ = ar{2};


rand('seed', 5);

fprintf('Nacitam...\n');
%pause;
%load('ex3data1.mat');
X=load('../ML_tables/features');
y=load(strcat('../ML_tables/is', categ));


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

tolerances = [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9];
res = [];

for tolerance = tolerances

    pred = predictOne(thetas, XTest, tolerance);

   
    TP = 0.0+ sum(pred&yTest);
    precision = TP/sum(pred);
    recall = TP/sum(yTest);
    if (sum(yTest)==0)
     recall = 1;
    endif



    Fscore = 2*(precision*recall)/(precision+recall);
    res = [res Fscore]
endfor

save(strcat('../ML_tables/res',lambdastr), 'res');

fprintf('\nTesting Set Accuracy: %f\n', mean(double(pred == yTest)) * 100);

pred = predictOne(thetas, XTrain, tolerance);

fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred == yTrain)) * 100);

