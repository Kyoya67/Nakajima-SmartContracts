// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts@4.6.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.6.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";
import "@openzeppelin/contracts@4.6.0/utils/Strings.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";
import "@openzeppelin/contracts@4.6.0/utils/Base64.sol";


contract TextNFT is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    mapping(uint256 => string) messages;
    
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("TextNFT", "TN") {
        nftMint("Hello World");
    }

    function nftMint(string memory message) public {
        _tokenIdCounter.increment();
        uint tokenId = _tokenIdCounter.current();
        messages[tokenId] = message;
        _mint(msg.sender, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage){
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns(string memory) {
        return string(messages[tokenId]);
    }
}