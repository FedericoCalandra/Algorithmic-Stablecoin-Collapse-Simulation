function [newMeanQuantity, newSigma] = computeGenericTokenGaussianParameters(meanQuantity, sigma)
%COMPUTESELLPROBABILITY compute the sell prob. of tokenA

constantSigma = 100;

delta = normrnd(0, sigma);
newMeanQuantity = meanQuantity + delta;
newSigma = constantSigma;

end