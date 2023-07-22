function [Q_a, Q_b, P_a, K, sellProb] = simulateLiquidityPool(n, T_a, T_b, initQ_a, ...
                                                      initQ_b, fee, sigma)
%SIMULATE LIQUIDITY POOL
%   This function is the entry point of the simulation.
%   Input:  n                -> number of samples (swaps)
%           initQ_a, initQ_b -> inital token quantities in the pool
%           initP_a, initP_b -> initial token prices
%   Output: Q_a, Q_b         -> token quantity variation arrays (length = n)
%           P_a              -> token price variation arrays (length = n)
%           K                -> Q_a * Q_b product variation
%   Hypothesis:
%           TokenB price P_b is stable to 1$ (e.g. USDC)
P_b = 1;

% creates an instance of the liquidity pool model
pool = LiquidityPool(T_a, T_b, initQ_a, initQ_b, fee);

% initialize K and set initial value
K = zeros(1, n+1);
K(1) = initQ_a * initQ_b;

% initializing arrays for efficiency
Q_a = zeros(1, n+1);
Q_b = zeros(1, n+1);
P_a = zeros(1, n+1);
sellProb = zeros(1, n+1);

% set initial values
Q_a(1) = initQ_a;
Q_b(1) = initQ_b;
P_a(1) = (K(1) / (initQ_a^2 + initQ_a));

% set the intial sell probability
p = 0.5;
sellProb(1) = 0.5;

for i = 2:n+1
    
    % compute new sell probability
    p = computeSellProbability(pool.getTokenPrice(T_a, P_b), p, sigma);
    sellProb(i) = p;
    
    % compute r (==1 -> sell, ==0 -> buy)
    r = rand(1,1);
    if r >= p
        r = 1;
    else
        r = 0;
    end
    
    % perform the swap for each sample and get new values of Q_a and Q_b
    if r == 0
        [Q_a(i), Q_b(i)] = pool.swap(T_a, 1);
    else 
        [Q_a(i), Q_b(i)] = pool.swap(T_a, -1);
    end
    
    % update tokenA price accordingly
    P_a(i) = pool.getTokenPrice(T_a, P_b);
    
    % update K
    K(i) = Q_a(i) * Q_b(i);
    
end

end



















