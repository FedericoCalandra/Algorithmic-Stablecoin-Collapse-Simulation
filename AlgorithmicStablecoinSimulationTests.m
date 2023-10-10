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
            
    end
    
end











