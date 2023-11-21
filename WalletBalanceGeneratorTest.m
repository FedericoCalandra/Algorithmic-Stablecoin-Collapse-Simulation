classdef WalletBalanceGeneratorTest < matlab.unittest.TestCase
    
    methods (Test)
        function testWalletDistributionInitialization(TestCase)
            C = 1000000;
            rate = 0.1;
            distr = WalletBalanceGenerator(C, rate);
            TestCase.verifyEqual(distr.TotalTokenSupply, C);
            TestCase.verifyEqual(distr.Rate, rate);
        end
        
        function testPlotDistribution(TestCase)
            % plot histogram of the probability distribution built from
            % a set of randomly generated wallets
            C = 1000000000;
            rate = 0.000001;
            distr = WalletBalanceGenerator(C, rate);
            
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

