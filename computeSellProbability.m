function [newQ, newSigma] = computeSellProbability(tokenPrice, q, sigma)
%COMPUTESELLPROBABILITY compute the sell prob. of tokenA


if tokenPrice > 0.95 && tokenPrice < 1.05
    delta = normrnd(0, sigma);
    newQ = q + delta;
    newSigma = computeSigma(tokenPrice);
elseif tokenPrice >= 1.05
    delta = normrnd(-computeMu(q), sigma);
    newQ = q + delta;
    newSigma = computeSigma(tokenPrice);
elseif tokenPrice <= 0.95
    delta = normrnd(computeMu(q), sigma);
    newQ = q + delta;
    newSigma = computeSigma(tokenPrice);
end

end

function mu = computeMu(tokenPrice)
x = abs(1 - tokenPrice);
s = 200;
a = 0.05;
t = 0.3;
mu = (2*s) * 1 ./ (1 + exp(-(x - a)/t)) - s;
end

% da implementare
function newSigma = computeSigma(tokenPrice)
newSigma = 1000;
end