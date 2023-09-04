function [newMeanQuantity, newSigma] = computeStablecoinGaussianParameters(tokenPrice, meanQuantity, sigma)
%COMPUTESELLPROBABILITY compute the sell prob. of tokenA

constantSigma = 100;

if tokenPrice > 0.95 && tokenPrice < 1.05
    delta = normrnd(0, sigma);
    newMeanQuantity = meanQuantity + delta;
    newSigma = constantSigma;
elseif tokenPrice >= 1.05
    delta = normrnd(-computeMu(tokenPrice), sigma);
    newMeanQuantity = meanQuantity + delta;
    newSigma = constantSigma;
elseif tokenPrice <= 0.95
    delta = normrnd(computeMu(tokenPrice), sigma);
    newMeanQuantity = meanQuantity + delta;
    newSigma = computeSigma(tokenPrice);
end

end

function mu = computeMu1(tokenPrice)
x = abs(1 - tokenPrice);
s = 200;
a = 0.05;
t = 1;
mu = (2*s) * 1 ./ (1 + exp(-(x - a)/t)) - s;
end

function mu = computeMu(tokenPrice)
x = abs(1 - tokenPrice);
a = 200;
b = 0.04;
c = 400;
mu = a * log10(x - b) + c;
end

function newSigma = computeSigma(tokenPrice)
x = abs(1 - tokenPrice);
a = 8000;
b = 0.04;
c = 16000;
newSigma = a * log10(x - b) + c;
end