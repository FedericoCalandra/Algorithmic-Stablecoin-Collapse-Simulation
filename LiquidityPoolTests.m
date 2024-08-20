classdef LiquidityPoolTests < matlab.unittest.TestCase
    
    methods (Test)
        function testPoolInitialization(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            Q_a = 100000;
            Q_b = 10000;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b);
            actValues = [pool.T_a, pool.T_b, pool.Q_a, pool.Q_b];
            expValues = [T_a, T_b, Q_a, Q_b];
            TestCase.verifyEqual(actValues, expValues);
        end
        
        function testPoolSingleTokenSwap(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            Q_a = 100000;
            Q_b = 10000;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b);
            K = Q_a * Q_b;
            expToken = T_b;
            expQuantity = Q_b - (K / (Q_a+1));
            [actToken, actQuantity] = pool.swap(T_a, 1);
            TestCase.verifyEqual(actToken, expToken);
            TestCase.verifyEqual(actQuantity, expQuantity);
        end
        
        function testPoolSwap(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            Q_a = 100000;
            Q_b = 10000;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b);
            K = Q_a * Q_b;
            swappedQuantity = 15;
            expToken = T_b;
            expQuantity = Q_b - (K / (Q_a+swappedQuantity));
            [actToken, actQuantity] = pool.swap(T_a, swappedQuantity);
            TestCase.verifyEqual(actToken, expToken);
            TestCase.verifyEqual(actQuantity, expQuantity);
        end
        
        function testMultipleSwaps(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            Q_a = 100000;
            Q_b = 10000;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b);
            K = Q_a * Q_b;
            expToken = T_b;
            expQuantity = (Q_b - (K / (Q_a+5))) - (Q_b - (K / (Q_a+3)));
            pool.swap(T_a, 3);
            [actToken, actQuantity] = pool.swap(T_a, 2);
            TestCase.verifyEqual(actToken, expToken);
            TestCase.verifyEqual(actQuantity, expQuantity);
        end
        
        function testPoolGetTokenPriceAfterSwap(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            Q_a = 100000;
            Q_b = 10000;
            P_b = 10;
            K = Q_a * Q_b;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b);
            
            pool.swap(T_a, 10);
            expValue = (K / ((Q_a+10)^2 + Q_a+10)) * P_b;
            actValue = pool.getTokenPrice(T_a, P_b);
            
            delta = expValue - actValue;
            
            TestCase.verifyLessThan(delta, 1e-10);
        end
        
        function testPoolSwapWithFee(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            Q_a = 100000;
            Q_b = 10000;
            K = Q_a * Q_b;
            f = 0.003;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b, f);
            fee = 10 * f;
            expToken = T_b;
            expQuantity = Q_b - (K / (Q_a+10 - fee));
            [actToken, actQuantity] = pool.swap(T_a, 10);
            TestCase.verifyEqual(actToken, expToken);
            TestCase.verifyEqual(actQuantity, expQuantity);
        end
        
        function testComputeSwapValue(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            Q_a = 100000;
            Q_b = 10000;
            K = Q_a * Q_b;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b);
            actValue = pool.computeSwapValue(T_a, 500);
            expValue = Q_b - (K / (Q_a + 500));
            TestCase.verifyEqual(actValue, expValue);            
        end
        
    end
    
end











