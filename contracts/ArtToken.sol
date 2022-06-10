// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts@4.5.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.5.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.5.0/utils/Counters.sol";


contract ArtToken is ERC721, Ownable {

  // NFT token counter
  using Counters for Counters.Counter;
  Counters.Counter private _tokensIds;

  // pricing of NFT tokens (price of the artwork)
  uint public fee;

  // data structure with the properties of the artwork
  struct Artwork {
    uint id;
    string name;
    uint dna;
    uint8 level;
    uint8 rarity;
  }

  // storage structure for keeping artworks
  Artwork[] public artworks;


  event NewArtwork(address indexed owner, uint id, uint dna);


  constructor(string memory _name, string memory _symbol, uint _fee) ERC721(_name, _symbol) {
    fee = _fee;
  }


  // NFT token price update
  function updateFee(uint _fee) external onlyOwner {
    fee = _fee;
  }

  // visualize the balance of the smart contract
  function infoSmartContract() public view returns(address, uint) {
    return (address(this), address(this).balance);
  }

  // obtaining all created NFT tokens (artworks)
  function getArtworks() public view returns(Artwork[] memory) {
    return artworks;
  }

  // obtaining a user's NFT tokens
  function getOwnerArtworks(address _owner) public view returns(Artwork[] memory) {
    Artwork[] memory result = new Artwork[](balanceOf(_owner));
    uint counterOwner = 0;
    for (uint i = 0; i < artworks.length; i++) {
      if (ownerOf(i) == _owner) {
        result[counterOwner] = artworks[i];
        counterOwner++;
      }
    }
    return result;
  }

  // NFT token patment
  function createRandomArtwork(string memory _name) public payable {
    require(msg.value >= fee, "Underpayment");
    _createArtwork(_name);
  }

  // extraction of ethers from the smart contract to the owner
  function withdraw() external payable onlyOwner {
    payable(owner()).transfer(address(this).balance);
  }

  //level up NFT token
  function levelUp(uint _artworkId) public {
    require(ownerOf(_artworkId) == msg.sender, "You can not access");
    artworks[_artworkId].level++;
  }

  // creation of a random number for NFT token properties
  function _createRandomNumber(uint _mod) internal view returns (uint) {
    return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % _mod;
  }

  // NFT token creation (artwork)
  function _createArtwork(string memory _name) internal {
    Artwork memory newArtwork = Artwork(_tokensIds.current(), _name, _createRandomNumber(10**16), 1, uint8(_createRandomNumber(1000)));
    artworks.push(newArtwork);
    _safeMint(msg.sender, newArtwork.id);
    emit NewArtwork(msg.sender, newArtwork.id, newArtwork.dna);
    _tokensIds.increment();
  }

}
