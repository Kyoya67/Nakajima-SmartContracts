// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts@4.6.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.6.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";
import "@openzeppelin/contracts@4.6.0/utils/Strings.sol";
import "@openzeppelin/contracts@4.6.0/utils/Base64.sol";



contract TestDisplay is ERC721URIStorage, Ownable {

    /**
     *@dev
     * - _tokenIdsはCountersの全関数が利用可能
    */
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    /**
     * @dev
     * 色の構造体を定義し、この配列変数xolorsを定義
     */
    struct Color {
        string name;
        string code;
    }

    Color[] public colors;


    /**
     *@dev
     * - URI設定時に誰がどのtokenIdに何のURIを設定したかを記録する。
    */
    event TokenURIChanged(address indexed sender, uint256 indexed tokenId, string uri);


    /**
     * @dev
     * - URI設定時に誰がどのtokenIdに何のURIを設定したか記録する
     */
    constructor() ERC721("TestDisplay", "TDC") {
        colors.push(Color("Yellow","#ffff00"));
        colors.push(Color("Whitesmoke","#f5f5f5"));
        colors.push(Color("Blue","#0000ff"));
        colors.push(Color("Pink","#ffc0cb"));
        colors.push(Color("Green","#008000"));
        colors.push(Color("Gold","#FFD700"));
        colors.push(Color("Purple","#800080"));
        colors.push(Color("Light Green","#90EE90"));
        colors.push(Color("Orange","#FFA500"));
        colors.push(Color("Gray","#808080"));
    }

    /**
     *@dev
     * - このコントラクトをデプロイしたアドレスだけがmint可能 onlyOwner
     * - tokenIdをインクリメント
     * - nftMint関数の実行アドレスにtokenIdを紐づけ
     * - mintの際にURIを設定
     * - EVENT発火 emit TokenURIChanged
    */
    function nftMint() public onlyOwner{
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        bytes32 hashed = keccak256(abi.encodePacked(newTokenId, block.timestamp));
        Color memory color1 = colors[uint256(hashed)%colors.length];
        Color memory color2 = colors[uint256(hashed)%(colors.length+1)];

        string memory imageData = _getImage(color1.code, color2.code);

        bytes memory metaData = abi.encodePacked(
            '{"name":"',
            'SmileOnchainNFT #',
            Strings.toString(newTokenId),
            '","description":"My full on chain NFT",',
            '"image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(imageData)),
            '"}'
        );

        string memory uri = string(abi.encodePacked("data:application/json;base64,",Base64.encode(metaData)));

        _mint(_msgSender(), newTokenId);

        _setTokenURI(newTokenId, uri);
        
        emit TokenURIChanged(_msgSender(), newTokenId, uri);
    }

    /**
     * @dev
    * - 引数で渡されるカラーコードを指定したSVGデータを返す
    */

    function _getImage(string memory colorCode1, string memory colorCode2) internal pure returns (string memory) {
        return (
            string(
                abi.encodePacked(
                    '<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg" style="background-color: ',
                    colorCode1,
                    '">',
                    '<circle cx="100" cy="100" r="90" fill="',
                    colorCode2,
                    '" stroke="black" stroke-width="2" />',
                    '<circle cx="70" cy="80" r="15" fill="black" />',
                    '<circle cx="130" cy="80" r="15" fill="black" />',
                    '<path d="M80 130 Q100 150 120 130" fill="none" stroke="black" stroke-width="3" />',
                    '</svg>'
                )
            )
        );
    }
}