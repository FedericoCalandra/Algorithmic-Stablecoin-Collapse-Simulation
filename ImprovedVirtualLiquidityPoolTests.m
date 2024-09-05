classdef ImprovedVirtualLiquidityPoolTests < matlab.unittest.TestCase

    methods (Test)
        function testPoolInitialization(TestCase)
            T_stable = Token("TokenA", false);
            T_volatile = Token("TokenB");
            BasePool = 10000;
            P_volatile = 10;
            PoolRecoveryPeriod = 36;
            pool = ImprovedVirtualLiquidityPool(T_stable, T_volatile, P_volatile, ...
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
            PoolRecoveryPeriod = 36;
            pool = ImprovedVirtualLiquidityPool(T_stable, T_volatile, P_volatile, ...
                BasePool, PoolRecoveryPeriod);
            K = BasePool^2;
            expValue = 1;
            pool.swap(T_stable, 1);
            actValue = pool.Delta;
            TestCase.verifyEqual(actValue, expValue);
        end

        function testPoolStableSwapReturnedValue(TestCase)
            T_stable = Token("TokenA");
            T_volatile = Token("TokenB");
            BasePool = 100000;
            P_volatile = 10;
            PoolRecoveryPeriod = 36;
            pool = ImprovedVirtualLiquidityPool(T_stable, T_volatile, P_volatile, ...
                BasePool, PoolRecoveryPeriod);
            K = BasePool^2;
            expValue = K / (BasePool * P_volatile) - K / ((BasePool + 100) * P_volatile );
            [~, actValue] = pool.swap(T_stable, 100);
            TestCase.verifyEqual(actValue, expValue);
        end

        function testPoolVolatileSwapReturnedValue(TestCase)
            T_stable = Token("TokenA");
            T_volatile = Token("TokenB");
            BasePool = 100000;
            P_volatile = 10;
            PoolRecoveryPeriod = 36;
            pool = ImprovedVirtualLiquidityPool(T_stable, T_volatile, P_volatile, ...
                BasePool, PoolRecoveryPeriod);
            K = BasePool^2;
            poolVolatile = K / (BasePool * P_volatile);
            expValue = BasePool - K / ((poolVolatile + 10) * P_volatile );
            [~, actValue] = pool.swap(T_volatile, 10);
            TestCase.verifyEqual(actValue, expValue);
        end

        function testMultipleSwaps(TestCase)
            T_stable = Token("TokenA");
            T_volatile = Token("TokenB");
            BasePool = 10000;
            P_volatile = 10;
            PoolRecoveryPeriod = 36;
            quantity = 2;
            pool = ImprovedVirtualLiquidityPool(T_stable, T_volatile, P_volatile, ...
                BasePool, PoolRecoveryPeriod);
            expValue = 2 * quantity;
            pool.swap(T_stable, quantity);
            pool.swap(T_stable, quantity);
            actValue = pool.Delta;
            TestCase.verifyEqual(actValue, expValue);
        end

        function testComputeSwapValue(TestCase)
            T_stable = Token("TokenA");
            T_volatile = Token("TokenB");
            BasePool = 10000;
            P_volatile = 10;
            PoolRecoveryPeriod = 36;
            pool = ImprovedVirtualLiquidityPool(T_stable, T_volatile, P_volatile, ...
                BasePool, PoolRecoveryPeriod);
            actValue = pool.computeSwapValue(T_volatile, 1);
            expValue = BasePool - BasePool^2 / ((BasePool/P_volatile + 1) * P_volatile);
            TestCase.verifyEqual(actValue, expValue);
        end

        function testUpdateVolatileTokenPrice(TestCase)
            T_stable = Token("TokenA");
            T_volatile = Token("TokenB");
            BasePool = 10000;
            P_volatile = 10;
            PoolRecoveryPeriod = 36;
            pool = ImprovedVirtualLiquidityPool(T_stable, T_volatile, P_volatile, ...
                BasePool, PoolRecoveryPeriod);
            pool.updateVolatileTokenPrice(3.0);
            actValue = pool.P_volatile;
            expValue = 3.0;
            TestCase.verifyEqual(actValue, expValue);
        end

        function testPoolReplenishing(TestCase)
            T_stable = Token("TokenA");
            T_volatile = Token("TokenB");
            BasePool = 10000;
            P_stable = 1;
            P_volatile = 10;
            PoolRecoveryPeriod = 3;
            pool = ImprovedVirtualLiquidityPool(T_stable, T_volatile, P_volatile, ...
                BasePool, PoolRecoveryPeriod);
            pool.swap(T_stable, 24);
            pool.swap(T_stable, 12);
            pool.swap(T_stable, 12);
            pool.restoreDelta(P_stable);
            pool.restoreDelta(P_stable);
            pool.restoreDelta(P_stable);
            deltaExpected = 0;
            delta = pool.Delta;
            TestCase.verifyEqual(delta, deltaExpected);
        end

        function testPoolReplenishingInCrisisScenario(TestCase)
            T_stable = Token("TokenA");
            T_volatile = Token("TokenB");
            BasePool = 10000;
            P_stable = 0.951;
            P_volatile = 10;
            PoolRecoveryPeriod = 4;
            pool = ImprovedVirtualLiquidityPool(T_stable, T_volatile, P_volatile, ...
                BasePool, PoolRecoveryPeriod);
            pool.swap(T_stable, 20);
            pool.swap(T_stable, 10);
            pool.swap(T_stable, 10);
            pool.restoreDelta(P_stable);
            pool.restoreDelta(P_stable);
            deltaExpected = 0;
            delta = pool.Delta;
            TestCase.verifyEqual(delta, deltaExpected);
        end
    end

end



