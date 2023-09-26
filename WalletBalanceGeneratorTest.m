classdef WalletBalanceGeneratorTest < matlab.unittest.TestCase
    
    methods (Test)
        function testWalletDistributionInitialization(TestCase)
            C = 1000000000;
            max = 100000000;
            distr = WalletDistribution(C, max);
            TestCase.verifyEqual(distr.Capitalization, C);
            TestCase.verifyEqual(distr.Max, max);
        end
        
        function testPlotDistribution(TestCase)
            C = 1000000000;
            max = 100000000;
            distr = WalletDistribution(C, max);
            n = 10000;
            x = zeros(1, n);
            for i = 1:n
                x(i) = distr.pickAWalletBalance();
            end
            x = sort(x);
            stem(x);
            histogram(x);
        end
        
    end
end

