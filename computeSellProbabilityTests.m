classdef computeSellProbabilityTests < matlab.unittest.TestCase
    
    methods (Test)
        function testSellProbability(TestCase)
            n = 1000;
            P1 = zeros(1, n+1);
            P1(1) = 0;
            for i = 2:n+1
                P1(i) = computeSellProbability(1, P1(i-1), 0.00001);
            end
            figure(1);
            subplot(2,1,1);
            plot(P1);
            title("Probability in normal conditions (0.95 < price < 1.05)");
            P2 = zeros(1, n+1);
            P2(1) = 0;
            price = linspace(0.95, 0.80, n+1);
            for i = 2:n+1
                P2(i) = computeSellProbability(price(i), P2(i-1), 0.00001);
            end
            subplot(2,1,2);
            plot(P2);
            title("Probability with high sell pressure (price < 0.95)");
        end
    end
    
end

