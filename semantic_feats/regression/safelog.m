function [res] = safelog(x)

    res = log(x);
    res(find(isinf(res)==1))=-1e100;