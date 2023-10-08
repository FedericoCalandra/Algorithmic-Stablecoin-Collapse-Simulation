
n = 1000;

T_stable = Token("TokenA");
T_volatile = Token("TokenB");
BasePool = 10000;
P_volatile = 10;
PoolRecoveryPeriod = 36;

sigma = 0.0001;

virtualPool = VirtualLiquidityPool(T_stable, T_volatile, P_volatile, ...
    BasePool, PoolRecoveryPeriod);

% initialize delta and price variation vecotors
d = zeros(1, n + 1);

% initialize wallet distribution
initialFreeTokenSupply = 3*BasePool;
maxBalance = initialFreeTokenSupply/3;
walletProbDistribution = WalletBalanceGenerator(initialFreeTokenSupply, ...
    maxBalance, 0, maxBalance/100);

% initialize the random purchaise generator
pool = LiquidityPool(T_stable, T_volatile, 1, 1, 0);
initialProbability = 0.5;
purchaseGenerator = PurchaseGenerator(pool, n, initialProbability, sigma, walletProbDistribution);


%% evenly spaced impulses

virtualPool.resetReplenishingSystem();

for i = 2:(n+1)
    
    if (mod(i, 100) == 0)
        virtualPool.swap(T_volatile, 1000);
    end
    
    d(i) = virtualPool.Delta;
    
    if (mod(i, 6) == 0)
        virtualPool.restoreDelta();
    end
end

plot(d);
xlim([0, n]);

%% exponential signal
a = 1.01;
m = 0:(n+1)/2;
x = a.^m;
y = zeros(1, n+1);

virtualPool.resetReplenishingSystem();

for i = 2:(n+1)
    if (i < (n+1)/2)
        virtualPool.swap(T_stable, x(i));
        y(i) = y(i-1) + x(i);    
    end
    
    d(i) = virtualPool.Delta;
    
    if (mod(i, 6) == 0)
        virtualPool.restoreDelta();
    end
end

plot(d);
hold on;
plot(y);
xlim([0, n]);
hold off;
%% random signal

virtualPool.resetReplenishingSystem();

for i = 2:n+1
    
    r = rand(1, 1);
    
    % choose if there will be a transaction in this iteration
    if (r > 0.5)
        [token, quantity] = purchaseGenerator.rndPurchase(initialFreeTokenSupply);
        
        [~, q] = virtualPool.swap(token, quantity*100);
    end
    
    d(i) = virtualPool.Delta;
    virtualPool.restoreDelta();
end

plot(d);
xlim([0, n]);
