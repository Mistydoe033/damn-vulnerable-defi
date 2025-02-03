# Naive Receiver

There’s a pool with 1000 WETH in balance offering flash loans. It has a fixed fee of 1 WETH. The pool supports meta-transactions by integrating with a permissionless forwarder contract. 

A user deployed a sample contract with 10 WETH in balance. Looks like it can execute flash loans of WETH.

All funds are at risk! Rescue all WETH from the user and the pool, and deposit it into the designated recovery account.

# Aim
deposit all WETH into the designated recovery account


# Attack Logic

1. Create an Array for Calls

    Initialize an array to hold 11 encoded function calls.

2. Add FlashLoan Calls

    Loop 10 times and add encoded flashLoan calls to the array.

3. Add Withdraw Call

    Add an encoded withdraw call to the 11th position in the array.

4. Combine All Calls

    Encode all the calls into a single multicall call.

5. Prepare Forwarder Request

    Create a request object with player details, nonce, and the encoded multicall data.

6. Sign the Request

    Hash the request and sign it using the player's private key.

7. Execute the Request

    Use the forwarder to execute the signed request and verify success.