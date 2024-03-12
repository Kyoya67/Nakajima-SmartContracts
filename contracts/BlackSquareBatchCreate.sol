// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts@4.6.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.6.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.6.0/utils/Strings.sol";
import "@openzeppelin/contracts@4.6.0/utils/Base64.sol";

contract BlackSquareBatchCreate is ERC721, Ownable {

    mapping(uint256 => string) public Squares;

    mapping(uint256 => uint256) public _tokenCreationTimestamps;

    uint256 timeLimited = 10 days;
    
    uint256 currentTokenId = 0;

    uint256 timeStampId = 1;

    constructor() ERC721("BlackSquareBatchCreate", "BSBC") {
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
            '"image": "data:image/svg+xml;base64,',
            Base64.encode(ArtWorkData),
            '"}'
        );
        return metadata;
    }

    function nftMint(uint256 tokenId) public {
        require(tokenId <= currentTokenId, "Invalid token ID");
        uint256 timeIndex = tokenId % 50 == 0 ? tokenId / 50 : tokenId / 50 + 1;
        require(block.timestamp <= _tokenCreationTimestamps[timeIndex] + timeLimited, "Token can't be minted, and it has been burnt.");
        _mint(msg.sender, tokenId);
    }

    function returnTimes(uint256 tokenId) public view returns(uint256){
        return _tokenCreationTimestamps[tokenId % 50 == 0 ? tokenId / 50 : tokenId / 50 + 1];
    }

    function batchCreate() public onlyOwner{
        currentTokenId += 50;
        _tokenCreationTimestamps[timeStampId++] = block.timestamp;
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