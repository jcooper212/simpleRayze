// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";


/// @title Rayze - Protocol for Payout NFTs
/// @author Jamshed Cooper
/// @notice We have defined the Rayze contract which will issue custom Payout NFT contracts
/// @dev PayoutNFTs are dynamically generated and deployed Rayze. RayzeToken is created with fixed supply at Rayze contract initiation

contract SimpleNFT is ERC721, Ownable {
  using Strings for uint256;
  using Counters for Counters.Counter;

  Counters.Counter private supply;
  address NFTOwner;

//NFT ipfs details
  string public uriPrefix; // = "ipfs://QmWC6NEbHNrAWy8x6BzR2rnWpkjzoVMrKxXgRxSpqNTgFh/";
  string public uriSuffix = ".json";
//  string public hiddenMetadataUri;

//NFT pricing details
  uint256 public cost; // = 0.00003 ether;
  uint256 public maxSupply; // = 10;
  uint256 public maxMintAmountPerTx; // = 2;

  bool public paused = true;
  bool public revealed = false;


  /// @notice Events
  event Minted(uint256 value);

  /// @notice Modifiers
  modifier mintCompliance(uint256 _mintAmount) {
    require(_mintAmount > 0 && _mintAmount <= maxMintAmountPerTx, "Invalid mint amount!");
    require(supply.current() + _mintAmount <= maxSupply, "Max supply exceeded!");
    _;
  }
  modifier validTokenId(uint256 _tokenId) {
    require(_tokenId <= supply.current(), "TokenID not valid");
    _;
  }

  /// @notice modifiers
      modifier restricted(){
          require(msg.sender == NFTOwner,'only admin');
          _;
      }


  constructor(string memory _name, string memory _symbol, uint256 _cost,
      uint256 _maxSupply, uint256 _maxMintAmountPerTx, string memory _uriPrefix, address _NFTOwner)
        ERC721(_name, _symbol)
  {
    //setHiddenMetadataUri("ipfs://QmRefJQtzu34N6jwAFfMyQRPJYm2HDmbHZ3ZifYhcbTYJ8/hidden.json");
    cost = _cost;
    uriPrefix = _uriPrefix;
    maxSupply = _maxSupply;
    maxMintAmountPerTx = _maxMintAmountPerTx;
    NFTOwner = _NFTOwner;
  }

  function totalSupply() public view returns (uint256) {
    return supply.current();
  }

  function mint(uint256 _mintAmount) public payable mintCompliance(_mintAmount) {
    require(!paused, "The contract is paused!");
    require(msg.value >= cost * _mintAmount, "Insufficient funds!");

    _mintLoop(msg.sender, _mintAmount);
    /**
    if (meta[msg.sender].amount == 0){
      users.push(msg.sender);
    }
    meta[msg.sender].amount += _mintAmount;

    if ((supply.current() + _mintAmount) >= startPayout){
      if (startPay == false){
        startBlock = block.number;
        lastPaidBlock = block.number;
        startPay = true;
      }
    }
    **/
    emit Minted(_mintAmount);
  }

  function mintForAddress(uint256 _mintAmount, address _receiver) public payable mintCompliance(_mintAmount) restricted {
    require(!paused, "The contract is paused!");
    require(msg.value >= cost * _mintAmount, "Insufficient funds!");

    _mintLoop(_receiver, _mintAmount);
    /**
    if (meta[_receiver].amount == 0){
      users.push(_receiver);
    }

    meta[_receiver].amount += _mintAmount;

    if ((supply.current() + _mintAmount) >= startPayout){
      if (startPay == false){
        startBlock = block.number;
        lastPaidBlock = block.number;
        startPay = true;
      }
    }
    **/

    emit Minted(_mintAmount);
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
    uint256 currentTokenId = 1;
    uint256 ownedTokenIndex = 0;

    while (ownedTokenIndex < ownerTokenCount && currentTokenId <= maxSupply) {
      address currentTokenOwner = ownerOf(currentTokenId);

      if (currentTokenOwner == _owner) {
        ownedTokenIds[ownedTokenIndex] = currentTokenId;

        ownedTokenIndex++;
      }

      currentTokenId++;
    }

    return ownedTokenIds;
  }
  function tokenOwnerAddress(uint256 _tokenId) public view returns(address){
    require(_tokenId <= maxSupply, "TokenId > maxSupply");
    return ownerOf(_tokenId);
  }

  function tokenURI(uint256 _tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(_tokenId),
      "ERC721: URI query for nonexistent token"
    );

    //if (revealed == false) {
    //  return hiddenMetadataUri;
    //}

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
        : "";
  }

  function setRevealed(bool _state) public { revealed = _state;}

  function setCost(uint256 _cost) public restricted { cost = _cost;}

  function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx) public restricted { maxMintAmountPerTx = _maxMintAmountPerTx;}

  //function setHiddenMetadataUri(string memory _hiddenMetadataUri) public restricted {
  //  hiddenMetadataUri = _hiddenMetadataUri;
  //}

  function setUriPrefix(string memory _uriPrefix) public restricted {
    uriPrefix = _uriPrefix;
  }

  function setUriSuffix(string memory _uriSuffix) public restricted {
    uriSuffix = _uriSuffix;
  }

  function setPaused(bool _state) public restricted {
    paused = _state;
  }

  function withdraw() public restricted {
    // This will transfer the remaining contract balance to the owner.
    // Do not remove this otherwise you will not be able to withdraw the funds.
    // =============================================================================
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
    // =============================================================================
  }

  function _mintLoop(address _receiver, uint256 _mintAmount) internal {
    for (uint256 i = 0; i < _mintAmount; i++) {
      supply.increment();
      _safeMint(_receiver, supply.current());
    }
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return uriPrefix;
  }
}
