classdef computeSellProbabilityTests < matlab.unittest.TestCase
    
    methods (Test)
        function testSellProbability(TestCase)
            n = 10000;
            meanQuantitiesNormal = zeros(1, n+1);
            meanQuantitiesNormal(1) = 0;
            for i = 2:n+1
                meanQuantitiesNormal(i) = computeSellProbability(1, meanQuantitiesNormal(i-1), 0.01);
            end
            figure(1);
            subplot(2,1,1);
            plot(meanQuantitiesNormal);
            title("Mean sell quantity variation in normal conditions (0.95 < price < 1.05)");
            meanQuantitiesSell = zeros(1, n+1);
            meanQuantitiesSell(1) = 0;
            price = linspace(0.95, 0.80, n+1);
            for i = 2:n+1
                meanQuantitiesSell(i) = computeSellProbability(price(i), meanQuantitiesSell(i-1), 0.01);
            end
            subplot(2,1,2);
            plot(meanQuantitiesSell);
            title("Mean sell quantity variation with high sell pressure (price < 0.95)");
        end
    end
    
end

