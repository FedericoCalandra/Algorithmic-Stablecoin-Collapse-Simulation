classdef PurchaseGeneratorTests < matlab.unittest.TestCase
    
    methods (Test)
        function testRWGInitialization(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            Q_a = 100000;
            Q_b = 10000;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b);
            n = 100000;
            initialTaPrice = 1;
            initialCapitalization = Q_a*initialTaPrice;
            maxAvailability = Q_a*initialTaPrice*0.33;
            walletProbDistribution = WalletBalanceGenerator(initialCapitalization, ...
                maxAvailability, maxAvailability/4, maxAvailability/3);
            rwg = PurchaseGenerator(pool, n, 0.5, 0.001, walletProbDistribution);
            TestCase.verifyEqual(rwg.P(1), 0.5);
            TestCase.verifyEqual(rwg.sigma, 0.001);
            TestCase.verifyEqual(size(rwg.P), [1 n]);
        end
        
        function testGenerate(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            Q_a = 100000;
            Q_b = 10000;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b);
            n = 100000;
            initialTaPrice = 1;
            totalTokenSupply = Q_a*initialTaPrice;
            maxAvailability = Q_a*initialTaPrice*0.33;
            totalFreeTokenSupply = totalTokenSupply/2;
            walletProbDistribution = WalletBalanceGenerator(totalTokenSupply, ...
                maxAvailability, maxAvailability/4, maxAvailability/3);
            rwg = PurchaseGenerator(pool, n, 0.5, 0.001, walletProbDistribution);
            t = rwg.rndPurchase(totalFreeTokenSupply);
            condition = false;
            if (t.is_equal(T_a) || t.is_equal(T_b))
                condition = true;
            end
            TestCase.verifyEqual(condition, true);
        end
        
        function testPVariation(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            Q_a = 100000;
            Q_b = 10000;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b);
            n = 1000;
            initialTaPrice = 1;
            totalTokenSupply = Q_a*initialTaPrice;
            maxAvailability = Q_a*initialTaPrice*0.33;
            totalFreeTokenSupply = totalTokenSupply/2;
            sigma = 0.01;
            walletProbDistribution = WalletBalanceGenerator(totalTokenSupply, ...
                maxAvailability, maxAvailability/4, maxAvailability/3);
            rwg = PurchaseGenerator(pool, n, 0.5, sigma, walletProbDistribution);
            
            td = zeros(1, n);
            for i = 1:n
                t = rwg.rndPurchase(totalFreeTokenSupply);
                if t.is_equal(T_a)
                    td(i) = 0;
                else
                    td(i) = 1;
                end
            end
            P = rwg.P;
            figure(1);
            plot(P);
            xlim([1 n]);
        end
        
        function testRandomQuantityGeneration(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            Q_a = 100000;
            Q_b = 100000;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b);
            n = 1000;
            initialTaPrice = 1;
            totalTokenSupply = Q_a*initialTaPrice;
            maxAvailability = Q_a*initialTaPrice*0.33;
            totalFreeTokenSupply = totalTokenSupply/2;
            walletProbDistribution = WalletBalanceGenerator(totalTokenSupply, ...
                maxAvailability, totalTokenSupply*0.1, maxAvailability/3);
            rwg = PurchaseGenerator(pool, n, 0.5, 0.001, walletProbDistribution);
            
            q = zeros(1, n);
            for j = 1:n
                q(j) = rwg.generateRandomQuantity(totalTokenSupply/totalFreeTokenSupply);
            end
            histogram(q);
        end
    end
    
end

