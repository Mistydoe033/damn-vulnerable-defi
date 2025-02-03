# Truster

More and more lending pools are offering flashloans. In this case, a new pool has launched that is offering flashloans of DVT tokens for free.

The pool holds 1 million DVT tokens. You have nothing.

To pass this challenge, rescue all funds in the pool executing a single transaction. Deposit the funds into the designated recovery account.

# Problem with TrusterLenderPool.sol

In the TrusterLenderPool contract, instead of enforcing a strict function like onFlashLoan() or some other defined method, it allows the borrower to specify any arbitrary function they want to call via the target.functionCall(data) line.

# Attack

take a flashloan and pass data to approve all Eth available to attacker smart contract.