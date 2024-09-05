classdef OriginalVirtualLiquidityPool < VirtualLiquidityPool
    % improved VIRTUAL LIQUIDITY POOL model
      
    methods
        function pool = OriginalVirtualLiquidityPool(varargin)
            % Construct an instance of this class
            pool@VirtualLiquidityPool(varargin);
        end
               
        function restoreDelta(self, ~)
            % update delta value
            self.Delta = self.Delta * (1 - 1/self.PoolRecoveryPeriod);            
        end
        
        function updateDelta(self, deltaVariation)
            self.Delta = self.Delta + deltaVariation;           
        end
        
        function resetReplenishingSystem(self)
            self.Delta = 0;            
        end
              
    end
        
end