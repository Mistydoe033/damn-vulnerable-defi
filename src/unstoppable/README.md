# Unstoppable

There's a tokenized vault with a million DVT tokens deposited. It’s offering flash loans for free, until the grace period ends.

To catch any bugs before going 100% permissionless, the developers decided to run a live beta in testnet. There's a monitoring contract to check liveness of the flashloan feature.

Starting with 10 DVT tokens in balance, show that it's possible to halt the vault. It must stop offering flash loans.


# Aim 
halt the vault

# Attack 
The attack works by messing with the two accounting systems. This is done by sending DVT tokens straight to the vault.

This throws off the balance, making convertToShares(totalSupply) != balanceBefore fail.

As a result, the flashLoan function is blocked because the systems don’t align, and the transaction always reverts, ignoring any 'user' input."