classdef LiquidityPool < handle
    %LIQUIDITY POOL model
    
    properties
        T_a  Token                                                          % token A type
        T_b  Token                                                          % token B type
        Q_a  double  {mustBePositive}                                       % initial token A balance
        Q_b  double  {mustBePositive}                                       % initial token B balance
        f    double  {mustBeNonnegative, mustBeLessThan(f, 1)} = 0          % fee : 0 <= f < 1
        K    double                                                         % invariant : K = Q_a * Q_b
        P_a  double  {mustBePositive}                                       % token A price
        P_b  double  {mustBePositive}                                       % token B price
    end
    
    methods
        function pool = LiquidityPool(varargin)
            %LiquidityPool() Construct an instance of this class
            pool.T_a = varargin{1};
            pool.T_b = varargin{2};
            pool.Q_a = varargin{3};
            pool.Q_b = varargin{4};
            if nargin > 4
                pool.f = varargin{5};
            end
            
            pool.K = pool.Q_a * pool.Q_b;
        end
        
        function [newQ_a, newQ_b] = swap(self, token, quantity)
            % Performs a swap operation within the pool
            
            fee = quantity * self.f;
            
            if token.is_equal(self.T_a)
                self.Q_a = self.Q_a + quantity;
                self.Q_b = self.K / (self.Q_a - fee);
            elseif token.is_equal(self.T_b)
                self.Q_b = self.Q_b + quantity;
                self.Q_a = self.K / (self.Q_b - fee);
            else
                disp("ERROR in swap()\nwrong token type");
            end
            
            % update K (due to fees)
            self.K = self.Q_a * self.Q_b;
            
            % output
            newQ_a = self.Q_a;
            newQ_b = self.Q_b;
        end
        
        function v = getTokenValueWRTOtherToken(self, token)
            if token.is_equal(self.T_a)
                v = self.K / ((self.Q_a^2) + self.Q_a);
            elseif token.is_equal(self.T_b)
                v = self.K / ((self.Q_b^2) + self.Q_b);
            else
                disp("ERROR in getTokenValueWRTOtherToken()\nwrong token type");
            end
        end
        
        function p = getTokenPrice(self, token, otherTokenPrice)
            % Returns token price in this liquidity pool instance
            v = getTokenValueWRTOtherToken(self, token);
            p = v * otherTokenPrice;
        end
        
    end
end



    
    
    
    
    