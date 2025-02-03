# Puppet V2

The developers of the [previous pool](https://damnvulnerabledefi.xyz/challenges/puppet/) seem to have learned the lesson. And released a new version.

Now they’re using a Uniswap v2 exchange as a price oracle, along with the recommended utility libraries. Shouldn't that be enough?

You start with 20 ETH and 10000 DVT tokens in balance. The pool has a million DVT tokens in balance at risk!

Save all funds from the pool, depositing them into the designated recovery account.


# Attack 

The issue here is with how a smart contract is figuring out the price of (DVT). To get the price, it uses a function called _getOracleQuote, which grabs the price from Uniswap by looking at how much of two tokens (WETH and DVT) are in a Uniswap pool.

Here's a quick rundown of the code:

The calculateDepositOfWETHRequired function takes in how much DVT you want, then calls _getOracleQuote to get the price, and adjusts it by multiplying by a factor (just some scaling).

_getOracleQuote checks the reserves of the two tokens (WETH and DVT) in the Uniswap pool and calculates the price based on that.

the problem: the contract is only using Uniswap's liquidity (the amount of tokens in the pool) to get the price. If the pool doesn’t have enough liquidity or if it’s manipulated, the price it gets could be way off. This makes the contract vulnerable to attacks where someone could mess with the price just by changing the liquidity in the pool.