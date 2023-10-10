classdef PurchaseGenerator < handle
    %   Generate a random purchase for a LiquidityPool
    %   If the Token is an algoritmic stablecoin two different stochastic
    %   models are implemented: one related to price stability, the other
    %   for peg loss situations
    
    properties
        Pool                                        LiquidityPool
        P                                           double
        sigma                                       double
        i                                           
        WalletBalanceGenerator                      WalletBalanceGenerator
        TotalInitialFreeTokenSupply                 double
    end
    
    methods
        function generator = PurchaseGenerator(liquidityPool, length, ...
                initialP, initialSigma, walletBalanceGenerator)
            % PARAMS
            %   liquidity pool                      - LiquidityPool
            %   number of simulation iterations     - decimal
            %   starting probability                - double
            %   starting sigma                      - double
            %   wallet balance generator            - WalletBalanceGenerator
            
            generator.Pool = liquidityPool;
            generator.P = zeros(1, length);
            generator.P(1) = initialP;
            generator.sigma = initialSigma;
            generator.i = 1;
            generator.WalletBalanceGenerator = walletBalanceGenerator;
            generator.TotalInitialFreeTokenSupply = walletBalanceGenerator.TotalTokenSupply;
        end
        
        function [token, quantity] = rndPurchase(self, totalFreeTokenSupply)
            % generate random tokens purchase
            
            % compute rate between current free tokens supply and initial 
            % token supply
            r = totalFreeTokenSupply / self.TotalInitialFreeTokenSupply;
            
            % compute delta
            delta = self.computeDelta();
            % add delta to P
            self.i = self.i + 1;
            newP = self.P(self.i-1) + delta;
            
            % is the new P beetwen 0 and 1?
            if (newP > 1)
                self.P(self.i) = 1;
            elseif (newP < 0)
                self.P(self.i) = 0;
            else
                self.P(self.i) = newP;
            end
            
            % choose a n from a random uniform distribution
            n = rand(1,1);
            
            if (n < self.P(self.i))
                token = self.Pool.T_a;
            else
                token = self.Pool.T_b;
            end
            
            quantity = self.generateRandomQuantity(r);
            
            if (token.is_equal(self.Pool.T_a) && quantity > totalFreeTokenSupply)
                quantity = totalFreeTokenSupply;
            end
                
        end
        
        function delta = computeDelta(self)
            % COMPUTE DELTA from a normal distribution
            
            normMean = 0;
            
            if (self.Pool.T_a.IsStablecoin == true)
                % get price deviation from peg
                priceDeviation = self.Pool.T_a.PEG - self.Pool.getTokenPrice(self.Pool.T_a, 1);
                
                if (abs(priceDeviation) > 0.05)
                    if (priceDeviation < -1)
                        priceDeviation = -1;
                    end
                    % the mean of the normal distribution is moved
                    normMean = priceDeviation * self.sigma;
                end
                delta = normrnd(normMean, self.sigma * 10);
            else
                delta = normrnd(normMean, self.sigma);
            end         
            
        end
        
        function quantity = generateRandomQuantity(self, smoothFactor)
            % select a random wallet from the wallets distribution
            randomWalletBalance = self.WalletBalanceGenerator.rndWalletBalance() * smoothFactor;
            
            % set sigma
            sigmaQuantity = randomWalletBalance/100;
            % if stablecoin, compute price deviation from peg
            if (self.Pool.T_a.IsStablecoin == true)
                % get price deviation from peg
                priceDeviation = self.Pool.T_a.PEG - self.Pool.getTokenPrice(self.Pool.T_a, 1);
                if (abs(priceDeviation) > 0.05)
                    % correct sigma
                    sigmaQuantity = randomWalletBalance / 2;
                end
            end
            
            % compute the truncated normal distribution
            untruncated = makedist('Normal', 0, sigmaQuantity);
            tnd = truncate(untruncated, 0, randomWalletBalance);
            
            % get random quantity
            quantity = random(tnd, 1, 1);
        end
        
    end
end

