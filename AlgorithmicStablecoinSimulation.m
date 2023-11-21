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
        InitialT_bPrice                             double
        PoolStable                                  LiquidityPool
        PoolVolatile                                LiquidityPool
        VirtualPool                                 VirtualLiquidityPool
        BaseVirtualPool                             double
        PoolRecoveryPeriod                          int32
        NumberOfIterations                          int64
        ExpRate                                     double = 0.0001
        Sigma                                       double = 0.0001
        PoolFee                                     double = 0.003
        WalletDistribution_stable                   WalletBalanceGenerator
        WalletDistribution_volatile                 WalletBalanceGenerator
        PurchaseGenerator_poolStable                PurchaseGenerator
        PurchaseGenerator_poolVolatile              PurchaseGenerator
    end

    methods

        function simulation = AlgorithmicStablecoinSimulation(varargin)
            simulation.T_a = varargin{1};
            simulation.T_b = varargin{2};
            simulation.InitialT_bPrice = varargin{3};
            simulation.TotalT_a = varargin{4};
            simulation.TotalT_b = varargin{5};
            simulation.FreeT_a = varargin{6};
            simulation.FreeT_b = varargin{7};
            simulation.BaseVirtualPool = varargin{8};
            simulation.PoolRecoveryPeriod = varargin{9};
            simulation.NumberOfIterations = varargin{10};
            if nargin > 10
                simulation.ExpRate = varargin{11};
                if nargin > 11
                    simulation.PoolFee = varargin{12};
                    if nargin > 12
                        simulation.Sigma = varargin{13};
                    end
                end
            end

            simulation.initializePools();
            simulation.initializeWalletDistributions(simulation.ExpRate);
            simulation.initializePurchaseGenerators();
        end

        function initializePools(self)
            % create 2 pools (T_a - USDC and T_b - USDC) and one virtual
            % pool (T_a - T_b) for the seigniorage process

            Q_a = self.TotalT_a - self.FreeT_a;
            Q_b = self.TotalT_b - self.FreeT_b;
            Q_c = self.InitialT_bPrice * Q_b;

            self.USDC = Token("USDC", true, 1);
            self.PoolStable = LiquidityPool(self.T_a, self.USDC, Q_a, Q_a, self.PoolFee);
            self.PoolVolatile = LiquidityPool(self.T_b, self.USDC, Q_b, Q_c, self.PoolFee);

            basePool = self.BaseVirtualPool;
            poolRecoveryPeriod = self.PoolRecoveryPeriod;
            self.VirtualPool = VirtualLiquidityPool(self.T_a, self.T_b, ...
                self.PoolVolatile.getTokenPrice(self.T_b, 1), basePool, ...
                poolRecoveryPeriod);
        end

        function initializeWalletDistributions(self, expRate)
            % initialize 2 wallet distributions

            self.WalletDistribution_stable = WalletBalanceGenerator(self.TotalT_a, expRate);
            self.WalletDistribution_volatile = WalletBalanceGenerator(self.TotalT_b, expRate);
        end

        function initializePurchaseGenerators(self)
            % initialize 2 random purchase generators
            initialProbability = 0.5;
            self.PurchaseGenerator_poolStable = PurchaseGenerator(self.PoolStable, ...
                self.NumberOfIterations, initialProbability, self.Sigma, self.WalletDistribution_stable);
            self.PurchaseGenerator_poolVolatile = PurchaseGenerator(self.PoolVolatile, ...
                self.NumberOfIterations, initialProbability, self.Sigma, self.WalletDistribution_volatile);
        end

        function [T_aPrices, T_bPrices, probA, probB, delta] = runSimulation(self)
            T_aPrices = zeros(self.NumberOfIterations, 1);
            T_bPrices = zeros(self.NumberOfIterations, 1);
            delta = zeros(self.NumberOfIterations, 1);

            % main loop
            for i = 1:self.NumberOfIterations

                self.stablePoolRandomPurchase();
                self.volatilePoolRandomPurchase();
                self.virtualPoolArbitrage();
                self.VirtualPool.restoreDelta();    % ATTENZIONE al concetto di tempo (qui abbiamo solo transazioni)

                delta(i) = self.VirtualPool.Delta;
                T_aPrices(i) = self.PoolStable.getTokenPrice(self.T_a, self.USDC.PEG);
                T_bPrices(i) = self.PoolVolatile.getTokenPrice(self.T_b, self.USDC.PEG);

            end

            probA = self.PurchaseGenerator_poolStable.P;
            probB = self.PurchaseGenerator_poolVolatile.P;

        end

        function stablePoolRandomPurchase(self)
            % stable pool random purchase
            [token, quantity] = self.PurchaseGenerator_poolStable.rndPurchase(self.FreeT_a, self.TotalT_a);

            T_aInPool_old = self.PoolStable.Q_a;
            self.PoolStable.swap(token, quantity);
            self.updateFreeT_a(T_aInPool_old);
        end

        function volatilePoolRandomPurchase(self)
            % volatile pool random purchase
            [token, quantity] = self.PurchaseGenerator_poolVolatile.rndPurchase(self.FreeT_b, self.TotalT_b);

            T_bInPool_old = self.PoolVolatile.Q_a;
            self.PoolVolatile.swap(token, quantity);
            self.updateFreeT_b(T_bInPool_old);
        end

        function out = virtualPoolArbitrage(self)
            % virtual pool arbitrage
            % The arbitrage operation is deterministic.
            % 1. a wallet is ramdomly choosen
            % 2. if there is an arbitrage opportunity, it is exploited
            % 3. the maximum amount of tokens used in the operation depends
            %    on the balance of the wallet
            out = 0;
            [token, quantity] = self.getQuantityRelatedToMaxYield();
            if quantity > 0
                if token.is_equal(self.T_a)
                    walletBalance = self.WalletDistribution_stable.rndWalletBalance();
                    [t, x] = self.PoolStable.swap(self.USDC, min(quantity, walletBalance));
                    [t, x] = self.VirtualPool.swap(t, x);
                    [~, out] = self.PoolVolatile.swap(t, x);
                else
                    walletBalance = self.WalletDistribution_volatile.rndWalletBalance();
                    [t, x] = self.PoolVolatile.swap(self.USDC, min(quantity, walletBalance));
                    [t, x] = self.VirtualPool.swap(t, x);
                    [~, out] = self.PoolStable.swap(t, x);
                end
            end
        end

        function [token, quantity] = getQuantityRelatedToMaxYield(self)
            x = 1;
            q = 0;

            yield1 = self.getArbitrageYield1(x);
            while(yield1 > 0)
                x = x + 1;
                if yield1 > self.getArbitrageYield1(x)
                    q = x - 1;
                    break;
                end
                yield1 = self.getArbitrageYield1(x);
            end

            yield2 = self.getArbitrageYield2(x);
            while(yield2 > 0)
                x = x + 1;
                if yield2 > self.getArbitrageYield2(x)
                    q = x - 1;
                    break;
                end
                yield2 = self.getArbitrageYield2(x);
            end

            if(yield1 > yield2)
                token = self.T_a;
            else
                token = self.T_b;
            end
            quantity = q;
        end

        function yield = getArbitrageYield1(self, quantity)
            % quanto si può guadagnare immettendo USDC nello StablePool?
            x = self.PoolStable.computeSwapValue(self.USDC, quantity);
            y = self.VirtualPool.computeSwapValue(self.T_a, x);
            USDC_out = self.PoolVolatile.computeSwapValue(self.T_b, y);
            yield = USDC_out - quantity;
        end

        function yield = getArbitrageYield2(self, quantity)
            % quanto si può guadagnare immettendo USDC nel VolatilePool?
            x = self.PoolVolatile.computeSwapValue(self.USDC, quantity);
            y = self.VirtualPool.computeSwapValue(self.T_b, x);
            USDC_out = self.PoolStable.computeSwapValue(self.T_a, y);
            yield = USDC_out - quantity;
        end

        function updateFreeT_a(self, Q_a_prev)
            self.FreeT_a = self.FreeT_a - (self.PoolStable.Q_a - Q_a_prev);
        end

        function updateFreeT_b(self, Q_b_prev)
            self.FreeT_b = self.FreeT_b - (self.PoolVolatile.Q_a - Q_b_prev);
        end

    end
end

