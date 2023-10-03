classdef WalletBalanceGeneratorTest < matlab.unittest.TestCase
    
    methods (Test)
        function testWalletDistributionInitialization(TestCase)
            C = 1000000;
            max = 100000000;
            distr = WalletBalanceGenerator(C, max, max/4, max/3);
            TestCase.verifyEqual(distr.TotalTokenSupply, C);
            TestCase.verifyEqual(distr.Max, max);
        end
        
        function testPlotDistribution(TestCase)
            % plot histogram of the probability distribution built from
            % a set of randomly generated wallets
            C = 1000000000;
            max = 100000000;
            distr = WalletBalanceGenerator(C, max, 0, max/100);
            
            % choose number of random wallets to consider
            n = 100000;
            
            x = zeros(1, n);
            for i = 1:n
                x(i) = distr.rndWalletBalance();
            end
            histogram(x);
        end
        
    end
end

