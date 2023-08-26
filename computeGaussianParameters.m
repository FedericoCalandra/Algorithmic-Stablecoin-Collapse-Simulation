function [newMeanQuantity, newSigma] = computeGaussianParameters(tokenPrice, meanQuantity, sigma)
%COMPUTESELLPROBABILITY compute the sell prob. of tokenA


if tokenPrice > 0.95 && tokenPrice < 1.05
    delta = normrnd(0, sigma);
    newMeanQuantity = meanQuantity + delta;
    newSigma = 100;
elseif tokenPrice >= 1.05
    delta = normrnd(-computeMu2(tokenPrice), sigma);
    newMeanQuantity = meanQuantity + delta;
    newSigma = computeSigma(tokenPrice);
elseif tokenPrice <= 0.95
    delta = normrnd(computeMu2(tokenPrice), sigma);
    newMeanQuantity = meanQuantity + delta;
    newSigma = computeSigma(tokenPrice);
end

end


function mu = computeMu1(tokenPrice)
x = abs(1 - tokenPrice);
s = 200;
a = 0.05;
t = 0.3;
mu = (2*s) * 1 ./ (1 + exp(-(x - a)/t)) - s;
end

function mu = computeMu2(tokenPrice)
x = abs(1 - tokenPrice);
a = 200;
b = 0.04;
c = 400;
mu = a * log10(x - b) + c;
end

% da implementare
function newSigma = computeSigma(tokenPrice)
newSigma = 1;
end