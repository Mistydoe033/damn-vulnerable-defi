# Selfie

A new lending pool has launched! It’s now offering flash loans of DVT tokens. It even includes a fancy governance mechanism to control it.

What could go wrong, right ?

You start with no DVT tokens in balance, and the pool has 1.5 million at risk.

Rescue all funds from the pool and deposit them into the designated recovery account.


# Attack

Looks like the governance system lets actions be executed, including calling the emergencyExit function in the pool contract. But only the governance contract itself can call it.

To make this work, we need to create an action in governance that triggers emergencyExit with our parameters. The problem? Queuing an action requires at least 50% of the total DVT token supply, and we don’t have that.

The workaround? The SelfiePool.sol contract has a flash loan function that lets us borrow a massive amount of DVT tokens with no collateral. That’ll give us enough voting power to queue the action, making this our way in for the exploit.