classdef LiquidityPool < handle
    %LIQUIDITY POOL model
    
    properties
        T_a  Token
        T_b  Token
        Q_a  double  {mustBePositive}
        Q_b  double  {mustBePositive}
        P_a  double  {mustBePositive}
        P_b  double  {mustBePositive}
        
        K    double
        C_a  double
        C_b  double
    end
    
    methods
        function pool = LiquidityPool(T_a, T_b, Q_a, Q_b, P_a, P_b)
            %LiquidityPool() Construct an instance of this class
            pool.T_a = T_a;
            pool.T_b = T_b;
            pool.Q_a = Q_a;
            pool.Q_b = Q_b;
            pool.P_a = P_a;
            pool.P_b = P_b;
            pool.K = Q_a * Q_b;
            pool.C_a = Q_a * P_a;
            pool.C_b = Q_b * P_b;
        end
        
        function [newQ_a, newQ_b] = swap(self, token, quantity)
            % Performs a swap operation within the pool
            
            if token.is_equal(self.T_a)
                self.Q_a = self.Q_a + quantity;
                self.Q_b = self.K / self.Q_a;
            elseif token.is_equal(self.T_b)
                self.Q_b = self.Q_b + quantity;
                self.Q_a = self.K / self.Q_b;
            else
                disp("ERROR in swap()\nwrong token type");
            end
            
            % update token prices
            self.P_a = self.C_a / self.Q_a;
            self.P_b = self.C_b / self.Q_b;
            
            % output
            newQ_a = self.Q_a;
            newQ_b = self.Q_b;
        end
        
        function [P_a, P_b] = getTokenPrices(self)
            % Returns token prices in this liquidity pool instance
            P_a = self.P_a;
            P_b = self.P_b;
        end
        
    end
end



    
    
    
    
    