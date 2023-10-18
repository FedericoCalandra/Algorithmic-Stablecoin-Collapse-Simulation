classdef AlgorithmicStablecoinSimulationTests < matlab.unittest.TestCase
    
    methods (Test)
        function testPoolsInitialization(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            totalT_a = 1000;
            totalT_b = 1000;
            freeT_a = 100;
            freeT_b = 100;
            Q_a = totalT_a - freeT_a;
            Q_b = totalT_b - freeT_b;
            sim = AlgorithmicStablecoinSimulation(T_a, T_b, totalT_a, totalT_b, freeT_a, freeT_b, 1); 
            actValues = [sim.PoolStable.Q_a, sim.PoolVolatile.Q_a];
            expValues = [Q_a, Q_b];
            TestCase.verifyEqual(actValues, expValues);
        end
        
        function testStableWalletInitialization(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            totalT_a = 1000;
            totalT_b = 1000;
            freeT_a = 100;
            freeT_b = 100;
            sim = AlgorithmicStablecoinSimulation(T_a, T_b, totalT_a, totalT_b, freeT_a, freeT_b, 1);
            w = sim.WalletDistribution_stable;
            actValues = [w.TotalTokenSupply, w.Max, w.PretruncMean, w.PretruncSD];
            expValues = [totalT_a, totalT_a/10, 0, totalT_a/1000];
            TestCase.verifyEqual(actValues, expValues);
        end
        
        function testUpdateFreeTaTb(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            totalT_a = 1000;
            totalT_b = 1000;
            freeT_a = 100;
            freeT_b = 100;
            sim = AlgorithmicStablecoinSimulation(T_a, T_b, totalT_a, totalT_b, freeT_a, freeT_b, 1);
            sim.PoolStable.swap(T_a, 10);
            expFreeT_a = freeT_a - 10;
            sim.PoolVolatile.swap(T_b, 3);
            expFreeT_b = freeT_b - 3;
            expValues = [expFreeT_a, expFreeT_b];
            sim.updateFreeT_a(T_a, 900);
            sim.updateFreeT_b(T_b, 900);
            actValues = [sim.FreeT_a, sim.FreeT_b];
            TestCase.verifyEqual(actValues, expValues);
        end
        
        function testArbitrageYields(TestCase)
            T_a = Token("TokenA");
            T_b = Token("TokenB");
            totalT_a = 1000;
            totalT_b = 1000;
            freeT_a = 900;
            freeT_b = 900;
            sim = AlgorithmicStablecoinSimulation(T_a, T_b, totalT_a, totalT_b, freeT_a, freeT_b, 1);
            sim.PoolStable.swap(T_a, 50);
            y1 = sim.getArbitrageYield1();
            y2 = sim.getArbitrageYield2();
        end
            
    end
    
end











