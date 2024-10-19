classdef ReservePurchaseGenerator < handle
    properties
        PoolStable                                      LiquidityPool
        TotalUSDCReserves                               double
        TotalStablecoinReserves                         double
        ThresholdIntervention                           double = [0.95, 1]
    end

    methods
        function reserveGenerator = ReservePurchaseGenerator(poolStable, ...
                initialUSDCReserves, initialStablecoinReserves, thresholdIntervention)
            reserveGenerator.PoolStable = poolStable;
            reserveGenerator.TotalUSDCReserves = initialUSDCReserves;
            reserveGenerator.TotalStablecoinReserves = initialStablecoinReserves;
            reserveGenerator.ThresholdIntervention = thresholdIntervention;
        end

        function reserveIntervention(self)
            T_a = self.PoolStable.T_a;
            USDC = self.PoolStable.T_b;

            % Price under the peg intervention
            if (self.PoolStable.getTokenPrice(T_a, USDC.PEG) < ...
                    T_a.PEG * self.ThresholdIntervention(1))
                pool = self.PoolStable;
                T_bSellQuantity = self.computeSellT_bQuantity(pool, ...
                    self.ThresholdIntervention(1));
                if (self.TotalUSDCReserves - T_bSellQuantity > 0)
                    [~, quantity] = pool.swap(USDC, T_bSellQuantity);
                    self.TotalUSDCReserves = self.TotalUSDCReserves - T_bSellQuantity;
                else
                    [~, quantity] = pool.swap(USDC, self.TotalUSDCReserves);
                    self.TotalUSDCReserves = 0;
                end
                self.TotalStablecoinReserves = self.TotalStablecoinReserves + quantity;
            end

            % Price above the peg intervention
            if (self.PoolStable.getTokenPrice(T_a, USDC.PEG) > self.ThresholdIntervention(2))
                pool = self.PoolStable;
                T_aSellQuantity = self.computeSellT_aQuantity(pool, self.ThresholdIntervention(2));
                if (self.TotalStablecoinReserves - T_aSellQuantity > 0)
                    [~, quantity] = pool.swap(T_a, T_aSellQuantity);
                    self.TotalStablecoinReserves = self.TotalStablecoinReserves - T_aSellQuantity;
                else
                    [~, quantity] = pool.swap(T_a, self.TotalStablecoinReserves);
                    self.TotalStablecoinReserves = 0;
                end
                self.TotalUSDCReserves = self.TotalUSDCReserves + quantity;
            end
        end

        function quantity = computeSellT_bQuantity(~, pool, targetT_aPrice)
            targetQ_a = (sqrt((targetT_aPrice + 4*pool.K) / ...
                targetT_aPrice) - 1) / 2;
            quantity = (pool.K / targetQ_a) - pool.Q_b;
        end

        function quantity = computeSellT_aQuantity(~, pool, targetT_aPrice)
            targetQ_a = (sqrt((targetT_aPrice + 4*pool.K) / ...
                targetT_aPrice) - 1) / 2;
            quantity = targetQ_a - pool.Q_a;
        end

    end
end


