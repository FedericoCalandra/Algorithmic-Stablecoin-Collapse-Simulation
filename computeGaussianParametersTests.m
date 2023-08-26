classdef computeGaussianParametersTests < matlab.unittest.TestCase
    
    methods (Test)
        function testSellProbability(TestCase)
            n = 10000;
            meanQuantitiesNormal = zeros(1, n+1);
            meanQuantitiesNormal(1) = 0;
            for i = 2:n+1
                meanQuantitiesNormal(i) = computeGaussianParameters(1, meanQuantitiesNormal(i-1), 0.01);
            end
            figure(1);
            subplot(3,1,1);
            plot(meanQuantitiesNormal);
            title("Mean sell quantity variation in normal conditions (0.95 < price < 1.05)");
            xlim([0 n+1]);
            
            meanQuantitiesSell = zeros(1, n+1);
            meanQuantitiesSell(1) = 0;
            price = linspace(0.95, 0.01, n+1);
            for i = 2:n+1
                meanQuantitiesSell(i) = computeGaussianParameters(price(i), meanQuantitiesSell(i-1), 0.01);
            end
            subplot(3,1,2);
            plot(meanQuantitiesSell);
            title("Mean sell quantity variation with high sell pressure (price < 0.95)");
            xlim([0 n+1]);
            
            sigmas = zeros(1, n+1);
            sigmas(1) = 100;
            for i = 2:n+1
                [~, sigmas(i)] = computeGaussianParameters(price(i), sigmas(i-1), 0.01);
            end
            subplot(3,1,3);
            plot(sigmas);
            title("Sigma variation with high sell pressure (price < 0.95)");
            xlim([0 n+1]);
        end
    end
    
end

