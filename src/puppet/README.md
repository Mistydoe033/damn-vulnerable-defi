# Puppet

There’s a lending pool where users can borrow Damn Valuable Tokens (DVTs). To do so, they first need to deposit twice the borrow amount in ETH as collateral. The pool currently has 100000 DVTs in liquidity.

There’s a DVT market opened in an old Uniswap v1 exchange, currently with 10 ETH and 10 DVT in liquidity.

Pass the challenge by saving all tokens from the lending pool, then depositing them into the designated recovery account. You start with 25 ETH and 1000 DVTs in balance.


# Attack 

So, the issue with this is how the contract figures out the price of the DamnValuableToken (DVT). It uses this function called _computeOraclePrice, which basically looks at the balance of the Uniswap pair to determine the token's value.

At first, this kinda makes sense

but the contract relies heavily on the balance of the liquidity pool to figure out the price of the DVT

an attacker can take advantage of this by messing with the pool’s balance and throw off the value of DVT. Here’s how that works

The attacker can dump DVT into the Uniswap liquidity pool. Since the pool suddenly has way more DVT, the price tanks.

so now DVT looks very cheap, the contract assumes that’s its the actual value.\

The attacker can deposit a tiny amount of ETH as collateral. Since the contract thinks DVT is worthless, it doesn’t ask for much ETH in return.

the attacker is now able to borrow (basically steal) all the DVT tokens from PuppetPool.

the issue is basically the contract trusting Uniswap’s liquidity way too much. 