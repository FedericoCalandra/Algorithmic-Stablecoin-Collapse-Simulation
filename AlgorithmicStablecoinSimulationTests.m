classdef AlgorithmicStablecoinSimulationTests < matlab.unittest.TestCase

    methods (Test)
        function testPoolsInitialization(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            initialT_bPrice = 10;
            totalT_a = 1000;
            totalT_b = 1000;
            freeT_a = 100;
            freeT_b = 100;
            Q_a = totalT_a - freeT_a;
            Q_b = totalT_b - freeT_b;
            sim = AlgorithmicStablecoinSimulation(T_a, T_b, initialT_bPrice, totalT_a, totalT_b, freeT_a, freeT_b, 1);
            actValues = [sim.PoolStable.Q_a, sim.PoolVolatile.Q_a];
            expValues = [Q_a, Q_b];
            TestCase.verifyEqual(actValues, expValues);
        end

        function testStableWalletInitialization(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            initialT_bPrice = 10;
            totalT_a = 1000;
            totalT_b = 1000;
            freeT_a = 100;
            freeT_b = 100;
            rate = 0.1;
            sim = AlgorithmicStablecoinSimulation(T_a, T_b, initialT_bPrice, totalT_a, totalT_b, freeT_a, freeT_b, 1, rate);
            w = sim.WalletDistribution_stable;
            actValues = [w.TotalTokenSupply, w.Rate];
            expValues = [totalT_a, rate];
            TestCase.verifyEqual(actValues, expValues);
        end

        function testUpdateFreeTaTb(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            initialT_bPrice = 10;
            totalT_a = 1000;
            totalT_b = 1000;
            freeT_a = 100;
            freeT_b = 100;
            sim = AlgorithmicStablecoinSimulation(T_a, T_b, initialT_bPrice, totalT_a, totalT_b, freeT_a, freeT_b, 1);
            sim.PoolStable.swap(T_a, 10);
            expFreeT_a = freeT_a - 10;
            sim.PoolVolatile.swap(T_b, 3);
            expFreeT_b = freeT_b - 3;
            expValues = [expFreeT_a, expFreeT_b];
            sim.updateFreeT_a(900);
            sim.updateFreeT_b(900);
            actValues = [sim.FreeT_a, sim.FreeT_b];
            TestCase.verifyEqual(actValues, expValues);
        end

        function testArbitrageYields(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            initialT_bPrice = 10;
            totalT_a = 1000000;
            totalT_b = 1000000;
            freeT_a = 700000;
            freeT_b = 700000;
            sim = AlgorithmicStablecoinSimulation(T_a, T_b, initialT_bPrice, ...
                totalT_a, totalT_b, freeT_a, freeT_b, 1, 0.0001, 0);
            sim.PoolStable.swap(sim.USDC, 10000);
            y1 = sim.getArbitrageYield1(1)
            y2 = sim.getArbitrageYield2(1)
        end

        function testPlotArbitrageYield(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            initialT_bPrice = 10;
            totalT_a = 1000000;
            totalT_b = 1000000;
            freeT_a = 700000;
            freeT_b = 700000;
            sim = AlgorithmicStablecoinSimulation(T_a, T_b, initialT_bPrice, ...
                totalT_a, totalT_b, freeT_a, freeT_b, 1, 0.0001, 0);
            sim.PoolStable.swap(sim.USDC, 12000);

            n = 1000;
            y1results = zeros(n, 1);
            y2results = zeros(n, 1);
            for q = 1:n
                y1results(q) = sim.getArbitrageYield1(q);
                y2results(q) = sim.getArbitrageYield2(q);
            end
            plot(y1results);
            hold on;
            plot(y2results);
            plot(zeros(n, 1), 'k--');
            xlim([0 (n+1)]);
            ylim([-80 30]);
            title('Arbitrage Yields');
            xlabel('Input USDC');
            ylabel('Yield in USDC');
        end

        function testArbitrageGetMaxYield(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            initialT_bPrice = 10;
            totalT_a = 1000000;
            totalT_b = 1000000;
            freeT_a = 700000;
            freeT_b = 700000;
            sim = AlgorithmicStablecoinSimulation(T_a, T_b, initialT_bPrice, ...
                totalT_a, totalT_b, freeT_a, freeT_b, 1, 0.0001, 0);
            sim.PoolStable.swap(sim.USDC, 12000);
            [token, q] = sim.getQuantityRelatedToMaxYield();
            TestCase.verifyEqual(token, T_b);
            TestCase.verifyEqual(q, 385);
        end

        function testArbitrageSystem(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            initialT_bPrice = 10;
            totalT_a = 1000000;
            totalT_b = 1000000;
            freeT_a = 700000;
            freeT_b = 700000;
            sim = AlgorithmicStablecoinSimulation(T_a, T_b, initialT_bPrice, ...
                totalT_a, totalT_b, freeT_a, freeT_b, 1, 0.0001, 0);
            sim.PoolStable.swap(sim.USDC, 12000);
            q = sim.virtualPoolArbitrage();
            epsilon = q - 400.4129619217711;
            TestCase.verifyLessThanOrEqual(epsilon, 0.0001);
        end

        function testSimulation(TestCase)
            T_a = Token("TokenA", true, 1);
            T_b = Token("TokenB");
            initialT_bPrice = 10;
            totalT_a = 1000000;
            totalT_b = 1000000;
            freeT_a = 700000;
            freeT_b = 700000;
            numberOfIterations = 10000;
            sim = AlgorithmicStablecoinSimulation(T_a, T_b, initialT_bPrice, ...
                totalT_a, totalT_b, freeT_a, freeT_b, numberOfIterations, 0.001, 0);
            [P_a, P_b] = sim.runSimulation();

            figure;
            plot(P_a);
            title('T_a price');
            xlabel('Iterations');
            ylabel('Price');
            figure;
            plot(P_b);
            title('T_b price');
            xlabel('Iterations');
            ylabel('Price');
        end

    end

end











