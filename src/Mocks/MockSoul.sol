// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { ERC721A } from "ERC721A/contracts/ERC721A.sol";
import { Ownable } from "openzeppelin/contracts/access/Ownable.sol";
import { Strings } from "openzeppelin/contracts/utils/Strings.sol";

contract MockSoulMate is ERC721A, Ownable {
    using Strings for uint256;

    string private uriExtension = ".json";
    string public baseURI;

    constructor() ERC721A("MockSoul", "MOCKSOUL") { }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), "Token does not exist.");
        return string(abi.encodePacked(baseURI, Strings.toString(_tokenId), uriExtension));
    }

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }
}
