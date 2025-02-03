# Side Entrance

A surprisingly simple pool allows anyone to deposit ETH, and withdraw it at any point in time.

It has 1000 ETH in balance already, and is offering free flashloans using the deposited ETH to promote their system.

You start with 1 ETH in balance. Pass the challenge by rescuing all ETH from the pool and depositing it in the designated recovery account.


# Examination 

contract has 3 functions flashloan(), deposit() and withdraw().

Flash Loan Mechanism:

    A flash loan is a type of uncollateralized loan where the borrower must repay the borrowed amount (plus any required fees) within the same transaction.

    If they fail, the transaction reverts.

    In a standard implementation, the lender contract itself ensures repayment by transferring the funds (borrowed amount + fees) back to itself.

# Problem 

Instead of handling repayment directly, it relies on the borrower to "repay" the loan by returning the funds to the contract during the same transaction.

The contract simply checks if the contract's balance after the loan matches its balance before the loan with:

    (address(this).balance >= balanceBefore). If this condition is not met, the transaction reverts.


# Attack 

use the deposit function to make the contract "think" the loan has been repaid and effectively drain the pool.

