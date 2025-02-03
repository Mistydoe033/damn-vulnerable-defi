// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";

struct Distribution {
    uint256 remaining;
    uint256 nextBatchNumber;
    mapping(uint256 batchNumber => bytes32 root) roots;
    mapping(address claimer => mapping(uint256 word => uint256 bits)) claims;
}

struct Claim {
    uint256 batchNumber;
    uint256 amount;
    uint256 tokenIndex;
    bytes32[] proof;
}

/**
 * An efficient token distributor contract based on Merkle proofs and bitmaps
 */
contract TheRewarderDistributor {
    using BitMaps for BitMaps.BitMap;

    address public immutable owner = msg.sender;

    mapping(IERC20 token => Distribution) public distributions;

    error StillDistributing();
    error InvalidRoot();
    error AlreadyClaimed();
    error InvalidProof();
    error NotEnoughTokensToDistribute();

    event NewDistribution(IERC20 token, uint256 batchNumber, bytes32 newMerkleRoot, uint256 totalAmount);

    function getRemaining(address token) external view returns (uint256) {
        return distributions[IERC20(token)].remaining;
    }

    function getNextBatchNumber(address token) external view returns (uint256) {
        return distributions[IERC20(token)].nextBatchNumber;
    }

    function getRoot(address token, uint256 batchNumber) external view returns (bytes32) {
        return distributions[IERC20(token)].roots[batchNumber];
    }

    function createDistribution(IERC20 token, bytes32 newRoot, uint256 amount) external {
        if (amount == 0) revert NotEnoughTokensToDistribute();
        if (newRoot == bytes32(0)) revert InvalidRoot();
        if (distributions[token].remaining != 0) revert StillDistributing();

        distributions[token].remaining = amount;

        uint256 batchNumber = distributions[token].nextBatchNumber;
        distributions[token].roots[batchNumber] = newRoot;
        distributions[token].nextBatchNumber++;

        SafeTransferLib.safeTransferFrom(address(token), msg.sender, address(this), amount);

        emit NewDistribution(token, batchNumber, newRoot, amount);
    }

    function clean(IERC20[] calldata tokens) external {
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20 token = tokens[i];
            if (distributions[token].remaining == 0) {
                token.transfer(owner, token.balanceOf(address(this)));
            }
        }
    }

    // Allow claiming rewards of multiple tokens in a single transaction
    function claimRewards(Claim[] memory inputClaims, IERC20[] memory inputTokens) external {
        Claim memory inputClaim; // A single claim structure
        IERC20 token; // Token to transfer rewards
        uint256 bitsSet; // accumulator for tracking processed claims in a batch
        uint256 amount; // amount to be transferred for the current claim

        // Iterate through each claim in the inputClaims array
        for (uint256 i = 0; i < inputClaims.length; i++) {
            inputClaim = inputClaims[i]; // Get the current claim

            uint256 wordPosition = inputClaim.batchNumber / 256; // Determine the position in the batch
            uint256 bitPosition = inputClaim.batchNumber % 256; // Determine the specific bit in the word

            // Check if the token is different from the previous one
            if (token != inputTokens[inputClaim.tokenIndex]) {
                // If a token is already set and it has been processed, revert
                if (address(token) != address(0)) {
                    if (!_setClaimed(token, amount, wordPosition, bitsSet)) revert AlreadyClaimed();
                }

                token = inputTokens[inputClaim.tokenIndex]; // Update the token for the current claim
                bitsSet = 1 << bitPosition; // Set the bit at the specific position for this claim
                amount = inputClaim.amount; // Set the amount for the current claim
            } else {
                // If the token is the same as the previous one, just accumulate the claim amount
                bitsSet = bitsSet | 1 << bitPosition; // Update bitsSet to include the current claim
                amount += inputClaim.amount; // Accumulate the total amount for the current batch
            }

            // Vulnerability: The claim is marked as processed only after the last occurrence.
            // This allows a malicious actor to receive multiple reward payouts for the same claim
            // before the system recognizes it as processed.
            
            // For the last claim in the array, ensure it is properly processed
            if (i == inputClaims.length - 1) {
                if (!_setClaimed(token, amount, wordPosition, bitsSet)) revert AlreadyClaimed();
            }

            // Generate the leaf to verify the Merkle proof for the claim
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender, inputClaim.amount));
            bytes32 root = distributions[token].roots[inputClaim.batchNumber]; // Get the Merkle root for the batch

            // Verify the Merkle proof for the claim
            if (!MerkleProof.verify(inputClaim.proof, root, leaf)) revert InvalidProof();

            // Transfer the reward amount to the claimant
            inputTokens[inputClaim.tokenIndex].transfer(msg.sender, inputClaim.amount);
        }
    }


    function _setClaimed(IERC20 token, uint256 amount, uint256 wordPosition, uint256 newBits) private returns (bool) {
        uint256 currentWord = distributions[token].claims[msg.sender][wordPosition];
        if ((currentWord & newBits) != 0) return false;

        // update state
        distributions[token].claims[msg.sender][wordPosition] = currentWord | newBits;
        distributions[token].remaining -= amount;

        return true;
    }
}
