// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;


import "./SimpleNFT.sol";
import "hardhat/console.sol";




/// @title Rayze - Protocol for Payout NFTs
/// @author Jamshed Cooper
/// @notice We have defined the Rayze contract which will issue custom Payout NFT contracts
/// @dev PayoutNFTs are dynamically generated and deployed Rayze. RayzeToken is created with fixed supply at Rayze contract initiation



/// @notice The Rayze protocol is able to create RayzeNFTs
contract SimpleFactory {
    address public owner;
    address [] public listRayzeNFTs;

/// @notice New Rayze NFT contract issued
//    event NewRayzeNFT(string str);


    constructor() {
        owner = msg.sender;
    }
    /// @notice Create a new RayzeNFT
    /// @dev requires a name, and owner as params. Returns the new workstream address
    function createSimpleNFT(string memory _NFTName, string memory _symbol, uint256 _cost, uint256 _supply, uint256 _maxMintAmountPerTx, string memory _uriPrefix)  external returns (address) {
        SimpleNFT newNFT = new SimpleNFT(_NFTName, _symbol, _cost, _supply, _maxMintAmountPerTx, _uriPrefix, msg.sender);
        listRayzeNFTs.push(address(newNFT));
        return address(newNFT);
    }

    function getSimpleNFTList(uint256 ix) external view returns(address){
      //require(ix < listRayzeNFTs.length,"index out of range");
      return listRayzeNFTs[ix];
    }

}
