classdef VirtualLiquidityPoolTests < matlab.unittest.TestCase
    
    methods (Test)
        function testPoolInitialization(TestCase)
            T_stable = Token("TokenA", false);
            T_volatile = Token("TokenB");
            BasePool = 10000;
            P_volatile = 10;
            PoolRecoveryPeriod = 0.1;
            pool = VirtualLiquidityPool(T_stable, T_volatile, P_volatile, ...
                BasePool, PoolRecoveryPeriod);
            actValues = [pool.T_stable, pool.T_volatile, pool.BasePool, ...
                pool.PoolRecoveryPeriod];
            expValues = [T_stable, T_volatile, BasePool, PoolRecoveryPeriod];
            TestCase.verifyEqual(actValues, expValues);
        end
        
        function testPoolSingleTokenSwap(TestCase)
            T_stable = Token("TokenA");
            T_volatile = Token("TokenB");
            BasePool = 10000;
            P_volatile = 10;
            PoolRecoveryPeriod = 0.1;
            pool = VirtualLiquidityPool(T_stable, T_volatile, P_volatile, ...
                BasePool, PoolRecoveryPeriod);
            K = BasePool^2;
            expValue = 1;
            delta = pool.swap(T_stable, 1);
            actValue = delta;
            TestCase.verifyEqual(actValue, expValue);
        end
        
        function testPoolSwap(TestCase)
            T_stable = Token("TokenA");
            T_volatile = Token("TokenB");
            BasePool = 10000;
            P_volatile = 10;
            PoolRecoveryPeriod = 0.1;
            pool = VirtualLiquidityPool(T_stable, T_volatile, P_volatile, ...
                BasePool, PoolRecoveryPeriod);
            K = BasePool^2;
            expValue = 100;
            delta = pool.swap(T_stable, 100);
            actValue = delta;
            TestCase.verifyEqual(actValue, expValue);
        end
        
        function testMultipleSwaps(TestCase)
            T_stable = Token("TokenA");
            T_volatile = Token("TokenB");
            BasePool = 10000;
            P_volatile = 10;
            PoolRecoveryPeriod = 0.5;
            pool = VirtualLiquidityPool(T_stable, T_volatile, P_volatile, ...
                BasePool, PoolRecoveryPeriod);
            expValue = 7 - 2*PoolRecoveryPeriod;
            pool.swap(T_stable, 2);
            delta = pool.swap(T_stable, 5);
            actValue = delta;
            TestCase.verifyEqual(actValue, expValue);
        end
        
        function testComputeSwapValue(TestCase)
            T_stable = Token("TokenA");
            T_volatile = Token("TokenB");
            BasePool = 10000;
            P_volatile = 10;
            PoolRecoveryPeriod = 0.5;
            pool = VirtualLiquidityPool(T_stable, T_volatile, P_volatile, ...
                BasePool, PoolRecoveryPeriod);
            [token, quantity] = pool.computeSwapValue(T_volatile, 1);
            expValues = [T_stable, (BasePool^2 * P_volatile) / BasePool - ...
                (BasePool^2 * P_volatile) / (BasePool + 1)];
            actValues = [token, quantity];
            TestCase.verifyEqual(actValues, expValues);
        end
        
        function testUpdateVolatileTokenPrice(TestCase)
            T_stable = Token("TokenA");
            T_volatile = Token("TokenB");
            BasePool = 10000;
            P_volatile = 10;
            PoolRecoveryPeriod = 0.5;
            pool = VirtualLiquidityPool(T_stable, T_volatile, P_volatile, ...
                BasePool, PoolRecoveryPeriod);
            pool.updateVolatileTokenPrice(3.0);
            actValue = pool.P_volatile;
            expValue = 3.0;
            TestCase.verifyEqual(actValue, expValue);
        end
    end
    
end


