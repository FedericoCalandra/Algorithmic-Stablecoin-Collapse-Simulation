function [Q_a, Q_b, P_a, K, P] = simulateLiquidityPool(n, T_a, T_b, initQ_a, ...
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

% set initial values
Q_a(1) = initQ_a;
Q_b(1) = initQ_b;
P_a(1) = (K(1) / (initQ_a^2 + initQ_a));

% initialize wallet distribution
initialFreeTokenSupply = 1*Q_a(1);
maxBalance = initialFreeTokenSupply/3;
walletProbDistribution = WalletBalanceGenerator(initialFreeTokenSupply, ...
    maxBalance, 0, maxBalance/100);   % RIVEDERE il portafogli più ricco può avere al più 1/3 della cap tot.

% initialize the random purchaise generator
initialProbability = 0.5;
purchaseGenerator = PurchaseGenerator(pool, n, initialProbability, sigma, walletProbDistribution);

totalFreeTa = initQ_a;

for i = 2:n+1
    
    % get token and quantity to be swapped
    [token, quantity] = purchaseGenerator.rndPurchase(totalFreeTa);
    
    % perform the swap for each sample and get new values of Q_a and Q_b
    [Q_a(i), Q_b(i)] = pool.swap(token, quantity);
    
    if (token.is_equal(T_a))
        totalFreeTa = totalFreeTa - (Q_a(i) - Q_a(i-1));
    else
        totalFreeTa = totalFreeTa + (Q_a(i-1) - Q_a(i));
    end
    
    % update tokenA price
    P_a(i) = pool.getTokenPrice(T_a, P_b);
    
    % update K
    K(i) = pool.getKValue();
    
end

P = purchaseGenerator.P;

end



















