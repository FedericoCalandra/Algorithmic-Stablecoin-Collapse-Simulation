classdef LiquidityPoolTests < matlab.unittest.TestCase
    
    methods (Test)
        function testPoolInitialization(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            Q_a = 100000;
            Q_b = 10000;
            P_a = 1;
            P_b = 10;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b, P_a, P_b);            
            actValues = [pool.T_a, pool.T_b, pool.Q_a, pool.Q_b, ...
                         pool.P_a, pool.P_b];
            expValues = [T_a, T_b, Q_a, Q_b, P_a, P_b];
            TestCase.verifyEqual(actValues, expValues);
        end
                
        function testPoolSingleTokenSwap(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            Q_a = 100000;
            Q_b = 10000;
            P_a = 1;
            P_b = 10;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b, P_a, P_b);
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
            P_a = 1;
            P_b = 10;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b, P_a, P_b);
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
            P_a = 1;
            P_b = 10;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b, P_a, P_b);
            K = Q_a * Q_b;
            expValues = [K / (K/(Q_a+2)+5), K/(Q_a+2)+5];
            pool.swap(T_a, 2);
            [newQ_a, newQ_b] = pool.swap(T_b, 5);
            actValues = [newQ_a, newQ_b];
            TestCase.verifyEqual(actValues, expValues);
        end
        
        function testPoolInitialPrices(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            Q_a = 100000;
            Q_b = 10000;
            P_a = 1;
            P_b = 10;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b, P_a, P_b);
            expValues = [P_a, P_b];
            [actP_a, actP_b] = pool.getTokenPrices();
            actValues = [actP_a, actP_b];
            TestCase.verifyEqual(actValues, expValues);
        end
        
        function testPoolPricesAfterSwap(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            Q_a = 100000;
            Q_b = 10000;
            P_a = 1;
            P_b = 10;
            K = Q_a * Q_b;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b, P_a, P_b);
            C_a = Q_a * P_a;
            C_b = Q_b * P_b;
            
            pool.swap(T_a, 10);
            expValues = [C_a / (Q_a+10), C_b / (K/(Q_a+10))];
            
            [actP_a, actP_b] = pool.getTokenPrices();
            
            actValues = [actP_a, actP_b];
            TestCase.verifyEqual(actValues, expValues);
        end
        
    end
    
end











