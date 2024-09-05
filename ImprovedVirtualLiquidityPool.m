classdef ImprovedVirtualLiquidityPool < VirtualLiquidityPool
    % improved VIRTUAL LIQUIDITY POOL model
    
    properties
        RestoreValues           double                                          % array used to bring delta back to 0
    end
    
    methods
        function pool = ImprovedVirtualLiquidityPool(varargin)
            % Construct an instance of this class
            pool@VirtualLiquidityPool(varargin)
            pool.RestoreValues = zeros(1, pool.PoolRecoveryPeriod);
        end
               
        function restoreDelta(self, stablecoinPrice)
            % update delta value

            values = flip(0.9:0.01:0.99);
            newRestoreValuesLength = self.PoolRecoveryPeriod;
            for i = 1:length(values)
                if (stablecoinPrice > values(i))
                    break;
                end
                newRestoreValuesLength = floor(self.PoolRecoveryPeriod * (1 - (i * 0.1)));
            end
            self.shrinkRestoreValues(newRestoreValuesLength);

            self.Delta = self.Delta - self.RestoreValues(1);
            self.RestoreValues(1) = 0;
            self.RestoreValues = circshift(self.RestoreValues, [0, -1]);
        end

        function shrinkRestoreValues(self, newLength) 
            s = sum(self.RestoreValues((newLength + 1):self.PoolRecoveryPeriod));
            self.RestoreValues((newLength + 1):self.PoolRecoveryPeriod) = 0;
            self.RestoreValues(1:newLength) = self.RestoreValues(1:newLength) + (s / newLength);
        end
        
        function updateDelta(self, deltaVariation)
            self.Delta = self.Delta + deltaVariation;
            self.RestoreValues = self.RestoreValues + (deltaVariation / double(self.PoolRecoveryPeriod));
        end
        
        function resetReplenishingSystem(self)
            self.Delta = 0;
            self.RestoreValues = zeros(1, self.PoolRecoveryPeriod);
        end
              
    end
        
end

