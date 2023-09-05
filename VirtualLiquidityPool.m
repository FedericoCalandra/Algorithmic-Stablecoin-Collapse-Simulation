classdef VirtualLiquidityPool < handle
    %VIRTUAL LIQUIDITY POOL model
    
    properties
        T_stable                Token                                                            % token A type
        T_volatile              Token                                                            % token B type
        P_volatile              double                                                           % price of T_volatile
        Delta                   double                                                           % the difference between the current T_stable pool size and its original base size
        K                       double                                                           % invariant : K = BasePool^2 * P_volatile
        BasePool                double {mustBeNonnegative}                                       % initial starting size of both pools
        PoolRecoveryPeriod      double {mustBeNonnegative}                                       % unit / swap, for bring delta to zero: e.g. 0.5/swap will bring delta to zero every 2 swaps
        MinSpread               double {mustBeNonnegative, mustBeLessThan(MinSpread, 1)} = 0     % minimum value of the spread tax
    end
    
    methods
        function pool = VirtualLiquidityPool(varargin)
            %LiquidityPool() Construct an instance of this class
            pool.T_stable = varargin{1};
            pool.T_volatile = varargin{2};
            pool.P_volatile = varargin{3};
            pool.BasePool = varargin{4};
            pool.PoolRecoveryPeriod = varargin{5};
            if nargin > 5
                pool.MinSpread = varargin{6};
            end
            
            pool.Delta = 0;
            pool.K = pool.BasePool^2 * pool.P_volatile;
        end
        
        function newDelta = swap(self, token, quantity)
            % Performs a swap operation within the virtual pool
            
            decrementDelta(self);
            poolVolatile = self.BasePool^2 / (self.BasePool + self.Delta);
            
            if token.is_equal(self.T_stable) && (self.BasePool + self.Delta + quantity) > 0
                self.Delta = self.Delta + quantity;
            elseif token.is_equal(self.T_volatile) && (poolVolatile + quantity) > 0
                self.Delta = self.BasePool / (poolVolatile + quantity);
            else
                if (self.BasePool + self.Delta + quantity) <= 0 || (poolVolatile + quantity) <= 0
                    error("ERROR in swap()\ntoken balance cannot be negative");
                else
                    error("ERROR in swap()\nwrong token type");
                end
            end
            
            newDelta = self.Delta;
        end
        
        function newDelta = decrementDelta(self)
            % update delta value at every swap
            
            self.Delta = self.Delta - (self.Delta * self.PoolRecoveryPeriod);
            newDelta = self.Delta;
        end
        
        function [outputToken, outputQuantity] = computeSwapValue(self, token, quantity)
            % compute the output value for a swap of specified quantity
            
            poolVolatile = self.BasePool^2 / (self.BasePool + self.Delta);
            
            if token.is_equal(self.T_stable) && (self.BasePool + self.Delta + quantity) > 0
                poolStable = self.BasePool + self.Delta + quantity;
                outputToken = self.T_volatile;
                outputQuantity = (self.K / (poolStable-quantity)) - (self.K / poolStable);
            elseif token.is_equal(self.T_volatile) && (poolVolatile + quantity) > 0
                poolVolatile = poolVolatile + quantity;
                outputToken = self.T_stable;
                outputQuantity = (self.K / (poolVolatile-quantity) - (self.K / poolVolatile));
            else
                if (self.BasePool + self.Delta + quantity) <= 0 || (poolVolatile + quantity) <= 0
                    error("ERROR in swap()\ntoken balance cannot be negative");
                else
                    error("ERROR in swap()\nwrong token type");
                end
            end
        end
        
        function updateVolatileTokenPrice(self, newPrice)
            % update volatile token price (oracles)
            
            self.P_volatile = newPrice;
        end
        
        
    end
    
    
end

