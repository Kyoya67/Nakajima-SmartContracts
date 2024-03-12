// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts@4.6.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.6.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.6.0/utils/Strings.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";
import "@openzeppelin/contracts@4.6.0/utils/Base64.sol";

contract LowGasBlackSquare is ERC721, Ownable {
    using Counters for Counters.Counter;

    mapping(uint256 => string) Squares;

    mapping(uint256 => uint256) private _tokenCreationTimestamps;

    uint256 timeLimited = 1 days;
    
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("<150*150px, #121212>", "BSN") {
        batchCreate();
        for(uint256 i = 1; i <= 50; i++){
            nftMint(i);
        }
    }

    function makeMetaData(uint256 tokenId) public pure returns(bytes memory) {

        bytes memory ArtWorkData = abi.encodePacked(
            "<svg width='150' height='150' xmlns='http://www.w3.org/2000/svg'><rect width='150' height='150' fill='#121212'/></svg>"
        );

        bytes memory metadata =abi.encodePacked(
            '{"name":"',
            '<150*150px, #121212> ',
            Strings.toString(tokenId % 50 == 0 ? tokenId / 50 : tokenId / 50 + 1),
            '-',
            Strings.toString(tokenId % 50 == 0 ? 50 : tokenId % 50),
            '","description":"Test",',
            '"animation_url": "data:image/svg+xml;base64,',
            Base64.encode(ArtWorkData),
            '"}'
        );
        return metadata;
    }

    function nftMint(uint256 tokenId) public {
        require(tokenId <= _tokenIdCounter.current(), "Invalid token ID");
        if(block.timestamp >= _tokenCreationTimestamps[tokenId] + timeLimited) {
            _burn(tokenId);
            revert("Token can't be minted, and it has been burnt.");
        }
        _mint(msg.sender, tokenId);
    }

    function batchCreate() public onlyOwner{
        for(uint256 i = 1; i <= 50; i++){
            _tokenIdCounter.increment();
            uint tokenId = _tokenIdCounter.current();
            _tokenCreationTimestamps[tokenId] = block.timestamp;
        } 
    }

    function _burn(uint256 tokenId) internal override(ERC721){
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721) returns(string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory json = Base64.encode(makeMetaData(tokenId));
        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}