const { expect } = require("chai");
const { ethers } = require("hardhat");

let varx, totalSupply, res, tkuri;
let SimpleFactory, nft1, nft2, SimpleNFT1, SimpleNFT2, rt, rw, meta, tokenAddr;
let owner1, addr1, addr2;

describe("SimpleNFT unit test",   function () {
  beforeEach("Setup SimpleFactory and create 2 NFT collections", async function (){
    //Initial setup
    [owner1, addr1, addr2] = await ethers.getSigners();
    SimpleNFT1 = await ethers.getContractFactory("SimpleNFT");
    SimpleNFT2 = await ethers.getContractFactory("SimpleNFT");

    //Deploy Simple
    SimpleFactory = await ethers.getContractFactory("SimpleFactory");
    SimpleFactory = await SimpleFactory.deploy();
    await SimpleFactory.deployed();

    //Create Simple NFT1
    nft1 = await SimpleFactory.createSimpleNFT("KiwiWorld", "KIW", 1, 100, 5, "ipfs://QmWC6NEbHNrAWy8x6BzR2rnWpkjzoVMrKxXgRxSpqNTgFh/");
    const addr = await SimpleFactory.getSimpleNFTList(0);
    nft1 = addr.toString();
    SimpleNFT1 = await SimpleNFT1.attach(nft1);
    await SimpleNFT1.setPaused(false);
    await SimpleNFT1.setRevealed(true);

    //Create Simple NFT2
    nft2 = await SimpleFactory.createSimpleNFT("FlyToast", "FLYT", 1, 1000, 5,
      "ipfs://QmWC6NEbHNrAWy8x6BzR2rnWpkjzoVMrKxXgRxSpqNTgFh/");

    nft2 = await SimpleFactory.getSimpleNFTList(1);
    //nft2 = addr2.toString();
    SimpleNFT2 = await SimpleNFT1.attach(nft2.toString());
    await SimpleNFT2.setPaused(false);
    await SimpleNFT2.setRevealed(true);

  });



  //SimpleNFT basic
  it('Simple NFT cost & total Supply', async function (){
    expect(await SimpleNFT1.cost()).to.equal("1");
    expect(await SimpleNFT1.totalSupply()).to.equal("0");
    expect(await SimpleNFT2.cost()).to.equal("1");
    expect(await SimpleNFT2.totalSupply()).to.equal("0");
  });

  //SimpleNFT mint
  it('Simple NFT mint', async function (){

    //mint
    await SimpleNFT1.mint(2,{ value: ethers.utils.parseEther("1") });
    expect(await SimpleNFT1.totalSupply()).to.equal("2");

    //mintForAddress
      await SimpleNFT1.mintForAddress(2,addr1.address,{ value: ethers.utils.parseEther("0.9") });
      expect(await SimpleNFT1.totalSupply()).to.equal("4");
      await SimpleNFT1.mintForAddress(2,addr2.address,{ value: ethers.utils.parseEther("0.9")});
      expect(await SimpleNFT1.totalSupply()).to.equal("6");
      await SimpleNFT1.mintForAddress(2,addr1.address,{ value: ethers.utils.parseEther("0.9")});
      expect(await SimpleNFT1.totalSupply()).to.equal("8");

      //walletOfOwner & tokenURI
      res = await SimpleNFT1.walletOfOwner(addr1.address);
      totalSupply = await SimpleNFT1.totalSupply();
      for (i = 0; i < res.length; i++){
        tkuri = await SimpleNFT1.tokenURI(res[i]);
        console.log("token id: ", res[i].toString(), "uri: ", tkuri);
      };

      //tokenOwnerAddress
      res = await SimpleNFT1.tokenOwnerAddress(7);
      expect(res.toString()).to.equal(addr1.address);


  });




});
