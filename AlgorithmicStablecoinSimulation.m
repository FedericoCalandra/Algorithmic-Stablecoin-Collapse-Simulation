classdef AlgorithmicStablecoinSimulation < handle
    % Algorithmic stablecoin system simulation
    
    properties
        T_a                                         Token
        T_b                                         Token
        USDC                                        Token
        FreeT_a                                     double
        TotalT_a                                    double
        FreeT_b                                     double
        TotalT_b                                    double
        PoolStable                                  LiquidityPool
        PoolVolatile                                LiquidityPool
        VirtualPool                                 VirtualLiquidityPool
        NumberOfIterations                          int64
        Sigma                                       double = 0.001
        PoolFee                                     double = 0.03
        WalletDistribution_stable                   WalletBalanceGenerator
        WalletDistribution_volatile                 WalletBalanceGenerator
        PurchaseGenerator_poolStable                PurchaseGenerator
        PurchaseGenerator_poolVolatile              PurchaseGenerator
    end
    
    methods
        
        function simulation = AlgorithmicStablecoinSimulation(varargin)
            simulation.T_a = varargin{1};
            simulation.T_b = varargin{2};
            simulation.TotalT_a = varargin{3};
            simulation.TotalT_b = varargin{4};
            simulation.FreeT_a = varargin{5};
            simulation.FreeT_b = varargin{6};
            simulation.NumberOfIterations = varargin{7};
            if nargin > 7
                simulation.PoolFee = varargin{8};
                simulation.Sigma = varargin{9};
            end
                     
            simulation.initializePools();
            simulation.initializeWalletDistributions();
            simulation.initializePurchaseGenerators();
        end
        
        function initializePools(self)
            % create 2 pools (T_a - USDC and T_b - USDC) and one virtual
            % pool (T_a - T_b) for the seigniorage process
            
            Q_a = self.TotalT_a - self.FreeT_a;
            Q_b = self.TotalT_b - self.FreeT_b;
            self.USDC = Token("USDC", true, 1);
            self.PoolStable = LiquidityPool(self.T_a, self.USDC, Q_a, Q_b, self.PoolFee);
            self.PoolVolatile = LiquidityPool(self.T_b, self.USDC, Q_a, Q_b, self.PoolFee);
            
            basePool = 10000;           % RIVEDERE
            poolRecoveryPeriod = 36;
            self.VirtualPool = VirtualLiquidityPool(self.T_a, self.T_b, ...
                self.PoolVolatile.getTokenPrice(self.T_b, 1), basePool, ...
                poolRecoveryPeriod);
        end
        
        function initializeWalletDistributions(self)
            % initialize 2 wallet distributions
            % hypothesis: 
            %   1. the wallet with the maximum balance can have at most
            %      1/10 of the total token supply
            %   2. the standard deviation of the pretruncated normal 
            %      distribution is equal to maxBalance/100
            maxBalance = self.TotalT_a/10;
            self.WalletDistribution_stable = WalletBalanceGenerator(self.TotalT_a, ...
                maxBalance, 0, maxBalance/100);
            maxBalance = self.TotalT_b/3;
            self.WalletDistribution_volatile = WalletBalanceGenerator(self.TotalT_b, ...
                maxBalance, 0, maxBalance/100);
        end
        
        function initializePurchaseGenerators(self)
            % initialize 2 random purchase generators
            initialProbability = 0.5;
            self.PurchaseGenerator_poolStable = PurchaseGenerator(self.PoolStable, ...
                self.NumberOfIterations, initialProbability, self.Sigma, self.WalletDistribution_stable);
            self.PurchaseGenerator_poolVolatile = PurchaseGenerator(self.PoolVolatile, ...
                self.NumberOfIterations, initialProbability, self.Sigma, self.WalletDistribution_volatile);
        end        
        
        function outputArg = runSimulation(self)
            % main loop
            for i = 1:self.NumberOfIterations
                
                self.stablePoolRandomPurchase();
                self.volatilePoolRandomPurchase();
                self.virtualPoolArbitrage();               
                
            end
        end
        
        function stablePoolRandomPurchase(self)
            % stable pool random purchase
            [token, quantity] = self.PurchaseGenerator_poolStable.rndPurchase(self.FreeT_a);
            T_aInPool_old = self.PoolStable.Q_a;
            self.PoolStable.swap(token, quantity);
            self.updateFreeT_a(token, T_aInPool_old);
        end
        
        function volatilePoolRandomPurchase(self)
            % volatile pool random purchase
            [token, quantity] = self.PurchaseGenerator_poolVolatile.rndPurchase(self.FreeT_b);
            T_bInPool_old = self.PoolVolatile.Q_a;
            self.PoolStable.swap(token, quantity);
            self.updateFreeT_b(token, T_bInPool_old);
        end
        
        function virtualPoolArbitrage(self)
            % virtual pool arbitrage
            % The arbitrage operation is deterministic.
            % 1. a wallet is ramdomly choosen
            % 2. if there is an arbitrage opportunity, it is exploited
            % 3. the maximum amount of tokens used in the operation depends
            %    by the balance of the wallet
            
            
        end
        
        function yield = getArbitrageYield1(self)
            % quanto si può guadagnare immettendo 1USDC nello StablePool?
            x = self.PoolStable.computeSwapValue(self.USDC, 1);
            y = self.VirtualPool.computeSwapValue(self.T_a, x);
            USDC_out = self.PoolVolatile.computeSwapValue(self.T_b, y);
            yield = USDC_out - 1;
        end
        
        function yield = getArbitrageYield2(self)
            % quanto si può guadagnare immettendo 1USDC nel VolatilePool?
            x = self.PoolVolatile.computeSwapValue(self.USDC, 1);
            y = self.VirtualPool.computeSwapValue(self.T_b, x);
            USDC_out = self.PoolStable.computeSwapValue(self.T_a, y);
            yield = USDC_out - 1;
        end
        
        function updateFreeT_a(self, token, Q_a_prev)
            if (token.is_equal(self.PoolStable.T_a))
                self.FreeT_a = self.FreeT_a - (self.PoolStable.Q_a - Q_a_prev);
            else
                self.FreeT_a = self.FreeT_a + (Q_a_prev - self.PoolStable.Q_a);
            end
        end
        
        function updateFreeT_b(self, token, Q_b_prev)
            if (token.is_equal(self.PoolVolatile.T_a))
                self.FreeT_b = self.FreeT_b - (self.PoolVolatile.Q_a - Q_b_prev);
            else
                self.FreeT_b = self.FreeT_b + (Q_b_prev - self.PoolStable.Q_a);
            end
        end
        
    end
end

