classdef ReservePurchaseGeneratorTests < matlab.unittest.TestCase

    methods (Test)
        function testRPGInitialization(TestCase)
            T_a = Token("TokenA");
            T_b = Token("USDC", true, true, 1);
            Q_a = 1000;
            Q_b = 1000;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b);
            totalStablecoinReserves = Q_a * 0.1;
            totalUSDCReserves = Q_a * 0.1;
            thresholdIntervention = 0.95;
            reserveGenerator = ReservePurchaseGenerator(pool, totalUSDCReserves, ...
                totalStablecoinReserves, thresholdIntervention);
            TestCase.assertEqual(reserveGenerator.PoolStable, pool);
            TestCase.assertEqual(reserveGenerator.TotalUSDCReserves, totalUSDCReserves);
            TestCase.assertEqual(reserveGenerator.TotalStablecoinReserves, totalStablecoinReserves);
            TestCase.assertEqual(reserveGenerator.ThresholdIntervention, thresholdIntervention);
        end

        function testPriceUnderThePegIntervention(TestCase)
            T_a = Token("TokenA");
            T_b = Token("USDC", true, true, 1);
            Q_a = 1000;
            Q_b = 1000;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b);
            totalStablecoinReserves = Q_a * 0.1;
            totalUSDCReserves = Q_a * 0.1;
            thresholdIntervention = 0.95;
            reserveGenerator = ReservePurchaseGenerator(pool, totalUSDCReserves, ...
                totalStablecoinReserves, thresholdIntervention);
            pool.swap(T_a, 100);
            reserveGenerator.reserveIntervention();
            fprintf("totalStablecoinReserves: %d\n", totalStablecoinReserves);
            fprintf("totalUSDCReserves: %d", totalUSDCReserves);
            epsilon = 1.0e-6;
            TestCase.verifyLessThanOrEqual(pool.getTokenPrice(T_a, 1) - thresholdIntervention, epsilon);
        end

        function testPriceAboveThePegIntervention(TestCase)
            T_a = Token("TokenA");
            T_b = Token("USDC", true, true, 1);
            Q_a = 1000;
            Q_b = 1000;
            pool = LiquidityPool(T_a, T_b, Q_a, Q_b);
            totalStablecoinReserves = Q_a * 0.1;
            totalUSDCReserves = Q_a * 0.1;
            reserveGenerator = ReservePurchaseGenerator(pool, totalUSDCReserves, ...
                totalStablecoinReserves, 1);
            pool.swap(T_b, 100);
            reserveGenerator.reserveIntervention();
            epsilon = 1.0e-6;
            TestCase.verifyLessThanOrEqual(pool.getTokenPrice(T_a, 1) - 1, epsilon);
        end

    end

end

