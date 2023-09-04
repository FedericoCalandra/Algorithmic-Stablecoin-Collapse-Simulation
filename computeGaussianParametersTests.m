classdef computeGaussianParametersTests < matlab.unittest.TestCase
    
    methods (Test)
        function testStablecoinSellProbability(TestCase)
            n = 10000;
            sigma = 0.05;
            meanQuantitiesNormal = zeros(1, n+1);
            meanQuantitiesNormal(1) = 0;
            for i = 2:n+1
                meanQuantitiesNormal(i) = computeStablecoinGaussianParameters(1, meanQuantitiesNormal(i-1), sigma);
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
                meanQuantitiesSell(i) = computeStablecoinGaussianParameters(price(i), meanQuantitiesSell(i-1), sigma);
            end
            subplot(3,1,2);
            plot(meanQuantitiesSell);
            title("Mean sell quantity variation with high sell pressure (price < 0.95)");
            xlim([0 n+1]);
            
            sigmas = zeros(1, n+1);
            sigmas(1) = 100;
            for i = 2:n+1
                [~, sigmas(i)] = computeStablecoinGaussianParameters(price(i), sigmas(i-1), sigma);
            end
            subplot(3,1,3);
            plot(sigmas);
            title("Sigma variation with high sell pressure (price < 0.95)");
            xlim([0 n+1]);
            
            str = sprintf("sigma = " + sigma); % annotation text
            position = [0.01 0.9 0.1 0.1]; % annotation position in figure coordinates
            annotation('textbox', position, 'string', str);
        end
        
        function testGenericTokenSellProbability(TestCase)
            n = 10000;
            sigma = 0.05;
            meanQuantitiesNormal = zeros(1, n+1);
            meanQuantitiesNormal(1) = 0;
            for i = 2:n+1
                meanQuantitiesNormal(i) = computeGenericTokenGaussianParameters(meanQuantitiesNormal(i-1), sigma);
            end
            figure(1);
            plot(meanQuantitiesNormal);
            title("Mean sell quantity variation");
            xlim([0 n+1]);
            
            str = sprintf("sigma = " + sigma);
            position = [0.01 0.9 0.1 0.1];
            annotation('textbox', position, 'string', str);
        end
        
    end
    
end

