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
            expValues = [Q_a+1; K / (Q_a+1)];
            [newQ_a, newQ_b] = pool.swap(T_a, 1);
            actValues = [newQ_a; newQ_b];
            TestCase.verifyEqual(actValues, expValues);
        end
        
        function testPoolSwap(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            Q_a = 100000;
            Q_b = 10000;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b);
            K = Q_a * Q_b;
            expValues = [Q_a+15, K / (Q_a+15)];
            [newQ_a, newQ_b] = pool.swap(T_a, 15);
            actValues = [newQ_a, newQ_b];
            TestCase.verifyEqual(actValues, expValues);
        end
        
        function testMultipleSwaps(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            Q_a = 100000;
            Q_b = 10000;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b);
            K = Q_a * Q_b;
            expValues = [K / (K/(Q_a+2)+5), K/(Q_a+2)+5];
            pool.swap(T_a, 2);
            [newQ_a, newQ_b] = pool.swap(T_b, 5);
            actValues = [newQ_a, newQ_b];
            TestCase.verifyEqual(actValues, expValues);
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
            expValues = [Q_a+10, K / (Q_a+10 - fee)];
            [actQ_a, actQ_b] = pool.swap(T_a, 10);
            actValues = [actQ_a, actQ_b];
            TestCase.verifyEqual(actValues, expValues);
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











