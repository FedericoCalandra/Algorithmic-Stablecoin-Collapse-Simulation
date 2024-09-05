classdef (Abstract) VirtualLiquidityPool < handle
    %VIRTUAL LIQUIDITY POOL model

    properties
        T_stable                Token                                                            % token A type
        T_volatile              Token                                                            % token B type
        P_volatile              double                                                           % price of T_volatile
        Delta                   double                                                           % the difference between the current T_stable pool size and its original base size
        K                       double                                                           % invariant : K = BasePool^2
        BasePool                double {mustBeNonnegative}                                       % initial starting size of both pools
        PoolRecoveryPeriod      {mustBeNonnegative}                                              % used to bring delta to zero: e.g. if =2 will bring delta to zero every 2 blocks
    end

    methods (Abstract)
        restoreDelta(self)
        updateDelta(self, deltaVariation)
    end

    methods
        function pool = VirtualLiquidityPool(varargin)
            %LiquidityPool() Construct an instance of this class
            input = varargin{1};
            pool.T_stable = input{1};
            pool.T_volatile = input{2};
            pool.P_volatile = input{3};
            pool.BasePool = input{4};
            pool.PoolRecoveryPeriod = input{5};
            pool.Delta = 0;
            pool.K = pool.BasePool^2;
        end

        function [outToken, outQuantity] = swap(self, token, quantity)
            % Performs a swap operation within the virtual pool

            outQuantity = self.computeSwapValue(token, quantity);

            if token.is_equal(self.T_stable)
                outToken = self.T_volatile;
                self.updateDelta(quantity);
            elseif token.is_equal(self.T_volatile)
                outToken = self.T_stable;
                self.updateDelta(-outQuantity);
            else
                if (self.BasePool + self.Delta + quantity) <= 0 || (poolVolatile + quantity) <= 0
                    error("ERROR in swap()\ntoken balance cannot be negative");
                else
                    error("ERROR in swap()\nwrong token type");
                end
            end

        end

        function outQuantity = computeSwapValue(self, token, quantity)
            % compute the output value for a swap of specified quantity
            if (quantity < 0)
                error("ERROR in swap()\nswap quantity cannot be negative");
            end

            poolStable = self.BasePool + self.Delta;
            poolVolatile = self.K * (1/self.P_volatile) / (poolStable);

            if (poolStable <= 0)
                error("ERROR in swap(): PoolStable must be positive");
            end

            if token.is_equal(self.T_stable)
                outQuantity = poolVolatile - self.K * (1/self.P_volatile) / (poolStable + quantity);
            elseif token.is_equal(self.T_volatile)
                outQuantity = poolStable - self.K * (1/self.P_volatile) / (poolVolatile + quantity);
            else
                error("ERROR in swap()\nwrong token type");
            end
        end

        function updateVolatileTokenPrice(self, newPrice)
            % update volatile token price (oracles)

            self.P_volatile = newPrice;
        end

    end

end

