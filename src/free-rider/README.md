# Free Rider

A new marketplace of Damn Valuable NFTs has been released! There’s been an initial mint of 6 NFTs, which are available for sale in the marketplace. Each one at 15 ETH.

A critical vulnerability has been reported, claiming that all tokens can be taken. Yet the developers don't know how to save them!

They’re offering a bounty of 45 ETH for whoever is willing to take the NFTs out and send them their way. The recovery process is managed by a dedicated smart contract.

You’ve agreed to help. Although, you only have 0.1 ETH in balance. The devs just won’t reply to your messages asking for more.

If only you could get free ETH, at least for an instant.


# Attack 

thy issue with the FreeRiderNFTMarketplace contract comes from the buyMany function. This function is used to buy multiple NFTs at once, but it internally calls the buy function, which is just for buying a single NFT. If you take a closer look at buyMany, you'll see that it doesn't check if the total amount of ETH being sent matches the combined price of all the NFTs. It just calls the buy function for each NFT, which only checks the price of a single NFT.

What this means is that you can buy as many NFTs as you want, but only pay the price of the most expensive one.

For example, if we want to buy three NFTs (id 1, 5, and 8) priced at 2, 5, and 4 ETH, we can get all three for just 5 ETH, since that's the price of the most expensive one. It's pretty simple to understand, but since I'm a little bored, I went ahead and drew a diagram anyway!