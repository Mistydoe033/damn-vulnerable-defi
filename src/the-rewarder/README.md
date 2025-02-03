# The Rewarder

A contract is distributing rewards of Damn Valuable Tokens and WETH.

To claim rewards, users must prove they're included in the chosen set of beneficiaries. Don't worry about gas though. The contract has been optimized and allows claiming multiple tokens in the same transaction.

Alice has claimed her rewards already. You can claim yours too! But you've realized there's a critical vulnerability in the contract.

Save as much funds as you can from the distributor. Transfer all recovered assets to the designated recovery account.

# Examination 

- **Distribution Struct**: Tracks remaining tokens, next batch numbers, Merkle roots for each batch, and user claims.  
- **Claim Struct**: Represents 1 claim, that has a batch number, amount, token index and Merkle proof.  

## Main Functions  

- **`createDistribution`**: Initializes a new token distribution with a Merkle root and amount.  

- **`claimRewards`**: Processes multiple claims in one call, transfers the rewards to the user
and marks the claim as claimed using _setClaimed.  

- **`_setClaimed`**: A private function that marks the claims as processed and updates the remaining token balance.  

# Attack 

use the claimRewards function to get multiple payouts for just one valid claim.

you need at least one valid, unclaimed reward for it to work.

then make a list of claims that are all the same but point to your valid claim.

after call the claimRewards function using your list 

then you transfer the funds right away to another address