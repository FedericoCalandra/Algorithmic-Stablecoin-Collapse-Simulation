function newP = computeSellProbability(tokenPrice, P, sigma)
%COMPUTESELLPROBABILITY compute the sell prob. of tokenA


if tokenPrice > 0.95 && tokenPrice < 1.05
    delta = normrnd(0, sigma);
    newP = P + delta;
elseif tokenPrice >= 1.05
    delta = normrnd(-computeMu(P), 8*sigma);
    newP = P + delta;
elseif tokenPrice <= 0.95
    delta = normrnd(computeMu(P), 8*sigma);
    newP = P + delta;
end

if newP > 1
    newP = 1;
elseif newP < 0
    newP = 0;
end
end

function mu = computeMu(tokenPrice)
x = abs(1 - tokenPrice);
scaleFactor = 0.001;
a = 0.051;
t = 0.0002;
mu = scaleFactor * 1 ./ (1 + exp(-(x - a)/t));
end