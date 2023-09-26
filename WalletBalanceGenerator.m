classdef WalletBalanceGenerator < handle
    % This is the random wallet balance generator
    %   At every iteration of the simulation, one wallet is randomly
    %   choosen. The wallet is rapresented by a double indicating the token
    %   availability (this parameter is used to determine the maximum
    %   spending capacity of the user)
    %   A truncated normal distribution is used
    
    properties
        Capitalization               double
        Wallets                      double
        PretruncMean                 double
        PretruncSD                   double
        Max                          double
        TND                                         % truncated normal distribution
    end
    
    methods
        function walletDistribution = WalletBalanceGenerator(initialCapitalization, ...
                maxAvailability, pretruncatedMean, pretruncatedSD)
            % PARAMS
            %   initial capitalization              - double
            %   maximum wallet availability         - double
            %   pretruncated mean                   - double
            %   pretruncated standard deviation     - double
            
            walletDistribution.Capitalization = initialCapitalization;
            walletDistribution.Max = maxAvailability;
            walletDistribution.PretruncMean = pretruncatedMean;
            walletDistribution.PretruncSD = pretruncatedSD;
            walletDistribution.TND = walletDistribution.computeTruncatedNormalDistribution();
        end
        
        function randomWalletBalance = rndWalletBalance(self)
            % A wallet is randomly choosen
            randomWalletBalance = random(self.TND, 1, 1);
        end
        
        function distr = computeTruncatedNormalDistribution(self)
            % Compute the truncated normal distribution with given params
            untruncated = makedist('Normal', self.PretruncMean, self.PretruncSD);
            truncated = truncate(untruncated, 0, self.Max);
            distr = truncated;
        end
        
    end
end

