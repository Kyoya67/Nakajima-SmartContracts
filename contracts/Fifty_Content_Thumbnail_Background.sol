// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts@4.6.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.6.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.6.0/utils/Strings.sol";
import "@openzeppelin/contracts@4.6.0/utils/Base64.sol";

contract Fifty_Content_Thumbnail_Backgroun is ERC721, Ownable {

    mapping(uint256 => bool) public tokensDeleted;

    uint256 public _currentTokenId = 0;

    constructor() ERC721("Fifty_Content_Thumbnail_Backgroun", "FCTB") {
        batchCreateDelete();
        for(uint256 i = 1; i <= 50; i++){
            _mint(msg.sender,i);
        }
    }

    function makeMetaData(uint256 tokenId) public pure returns(bytes memory) {

        bytes memory ArtWorkData = abi.encodePacked(
            "<svg width='15' height='15' xmlns='http://www.w3.org/2000/svg'><rect width='15' height='15' fill='#121212'/></svg>"
        );

        bytes memory metadata =abi.encodePacked(
            '{"name":"',
            'FCTB <15*15px, #121212> ',
            Strings.toString(tokenId % 50 == 0 ? tokenId / 50 : tokenId / 50 + 1),
            '-',
            Strings.toString(tokenId % 50 == 0 ? 50 : tokenId % 50),
            '","description":"",',
            '"image": "data:image/svg+xml;base64,',
            Base64.encode(ArtWorkData),
            '"}'
        );
        return metadata;
    }

    function batchMintable(uint256 currentTokenId) public view returns(uint8[] memory) {
        uint8[] memory mintableStatuses = new uint8[](currentTokenId);

        for (uint256 i = 1; i <= currentTokenId; i++) {
            //ミント可能
            if (currentTokenId > 50) {
                if (i > currentTokenId - 50) {
                    mintableStatuses[i - 1] = 2;
                    continue;
                } 
            }

            // トークンの所有者がいるかチェック
            try this.ownerOf(i) {
                mintableStatuses[i - 1] = 0; // 所有者がいる
            } catch {
                // 所有者がいない＝Burnされた
                mintableStatuses[i - 1] = 1;
            }
        }
        return mintableStatuses;
    }

    function nftMint(uint256 tokenId) public {
        require(tokenId <= _currentTokenId, "Invalid token ID");
        require(!tokensDeleted[tokenId], "This NFT has already been burned");

        if (_currentTokenId > 50) {
            bool isValid = true;
            uint256 baseIndex = _currentTokenId - 50;
            for (uint256 i = 1; i <= 50; i++) {
                uint256 holdIndex = baseIndex + i; 
                try this.ownerOf(holdIndex) {
                    if (this.ownerOf(holdIndex) == msg.sender) {
                        isValid = false;
                        break; 
                    }
                } catch {
                    continue;
                }
            }
            require(isValid, "You reached limitation of mint");
        }

        _mint(msg.sender, tokenId);
    }

    function batchCreateDelete() public onlyOwner{
        require(_currentTokenId <= 1280, "Maximum NFT minted");
        _currentTokenId += 50;

        // この関数が最初に実行された場合、以降の処理をスキップする
        if (_currentTokenId <= 100) {
            return; // ここで処理を終了し、後続の処理をスキップ
        }

        uint256 baseIndex = _currentTokenId - 100;
        for (uint8 i = 1; i <= 50; i++) {
            uint256 burnIndex = baseIndex + i;
            try this.ownerOf(burnIndex) {
                // トークンが所有されている場合は何もしない
                continue;
            } catch {
                // トークンがミントされていない場合は、tokensDeletedに記録する
                tokensDeleted[burnIndex] = true;
            }
        }
    }

    function tokenURI(uint256 tokenId) public view override(ERC721) returns(string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory json = Base64.encode(makeMetaData(tokenId));
        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}

    mapping(uint256 => uint256) public _tokenCreationTimestamps;

    mapping(uint256 => bool) public tokensDeleted;

    uint256 timeLimited = 30 minutes;
    
    uint256 public currentTokenId = 0;

    uint256 timeStampId = 1;

    constructor() ERC721("Fifty_Content_Thumbnail_Background", "FCTB") {
        batchCreateDelete();
        for(uint256 i = 1; i <= 50; i++){
            _mint(msg.sender,i);
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

    function batchMintable(uint256 _currentTokenId) public view returns(uint8[] memory) {
        uint8[] memory mintableStatuses = new uint8[](tokenId);
        for (uint256 i = 1; i <= _currentTokenId; i++) {
            uint256 timeIndex = i % 50 == 0 ? i / 50 : i / 50 + 1;
            // トークンの所有者がいるかチェック
            try this.ownerOf(i) {
                mintableStatuses[i - 1] = 0; // 所有者がいる
            } catch {
                // 所有者がいない場合、ミント可能かどうかをチェック
                if (block.timestamp <= _tokenCreationTimestamps[timeIndex] + timeLimited) {
                    mintableStatuses[i - 1] = 1; // ミント可能
                } else {
                    mintableStatuses[i - 1] = 2; // ミント不可能
                }
            }
        }
        return mintableStatuses;
    }

    function nftMint(uint256 tokenId) public {
        require(tokenId <= currentTokenId, "Invalid token ID");
        require(!tokensDeleted[tokenId], "This NFT has already been burned");
        _mint(msg.sender, tokenId);
    }

    function batchCreateDelete() public onlyOwner{
        currentTokenId += 50;
        _tokenCreationTimestamps[timeStampId++] = block.timestamp;

        // この関数が最初に実行された場合、以降の処理をスキップする
        if (currentTokenId <= 100) {
            return; // ここで処理を終了し、後続の処理をスキップ
        }

        uint256 BurnIndex = currentTokenId - 100;
        for (uint8 i = 1; i <= 50; i++) {
            uint256 tokenId = BurnIndex + i;
            try this.ownerOf(tokenId) {
                // トークンが所有されている場合は何もしない
                continue;
            } catch {
                // トークンがミントされていない場合は、tokensDeletedに記録する
                tokensDeleted[tokenId] = true;
            }
        }
    }


    function tokenURI(uint256 tokenId) public view override(ERC721) returns(string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory json = Base64.encode(makeMetaData(tokenId));
        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}
