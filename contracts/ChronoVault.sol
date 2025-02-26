// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ChronoVault is ERC721URIStorage, Ownable {
    IERC20 public usdcToken;

    struct Watch {
        bytes32 id;
        bool isAuthenticated;
        uint256 price;
        bool isListed;
        address manufacturer;
    }

    mapping(uint256 => Watch) public watches;
    mapping(address => bool) public allowlist;

    constructor(
        IERC20 _usdcToken
    ) ERC721("ChronoVault", "WATCH") Ownable(msg.sender) {
        usdcToken = _usdcToken;
    }

    event WatchMinted(
        bytes32 id,
        address to,
        uint256 price,
        address manufacturer
    );
    event WatchAuthenticated(bytes32 id);
    event WatchListed(bytes32 id);
    event WatchUnlisted(bytes32 id);
    event WatchPriceUpdated(bytes32 id, uint256 newPrice);
    event WatchBought(bytes32 id, address buyer);
    event WatchBurned(bytes32 id);

    function addToAllowlist(address _address) public onlyOwner {
        allowlist[_address] = true;
    }

    function removeFromAllowlist(address _address) public onlyOwner {
        allowlist[_address] = false;
    }

    function mintWatch(
        address _to,
        string memory _tokenURI,
        uint256 _price,
        address _manufacturer
    ) public returns (bytes32) {
        require(allowlist[msg.sender], "User is not authorized to mint");
        bytes32 watchId = keccak256(
            abi.encodePacked(block.timestamp, _tokenURI)
        );
        _safeMint(_to, uint256(watchId));
        _setTokenURI(uint256(watchId), _tokenURI);
        watches[uint256(watchId)] = Watch(
            watchId,
            false,
            _price,
            false,
            _manufacturer
        );
        emit WatchMinted(watchId, _to, _price, _manufacturer);
        return watchId;
    }

    function authenticateWatch(bytes32 _watchId) public returns (bytes32) {
        require(
            watches[uint256(_watchId)].manufacturer == msg.sender,
            "User is not the manufacturer"
        );
        watches[uint256(_watchId)].isAuthenticated = true;
        emit WatchAuthenticated(_watchId);
        return _watchId;
    }

    function listWatch(bytes32 _watchId) public returns (bytes32) {
        require(
            ownerOf(uint256(_watchId)) == msg.sender,
            "User is not the owner of the watch"
        );
        require(watches[uint256(_watchId)].price > 0, "Price is not set");
        require(
            watches[uint256(_watchId)].isAuthenticated,
            "Watch is not authenticated by manufacturer"
        );
        watches[uint256(_watchId)].isListed = true;
        emit WatchListed(_watchId);
        return _watchId;
    }

    function unlistWatch(bytes32 _watchId) public returns (bytes32) {
        require(
            ownerOf(uint256(_watchId)) == msg.sender,
            "User is not the owner of the watch"
        );
        require(watches[uint256(_watchId)].isListed, "Watch is not listed");
        watches[uint256(_watchId)].isListed = false;
        emit WatchUnlisted(_watchId);
        return _watchId;
    }

    function updateWatchPrice(
        bytes32 _watchId,
        uint256 _newPrice
    ) public returns (bytes32, uint256) {
        require(ownerOf(uint256(_watchId)) == msg.sender, "Not watch owner");
        watches[uint256(_watchId)].price = _newPrice;
        emit WatchPriceUpdated(_watchId, _newPrice);
        return (_watchId, _newPrice);
    }

    function buyWatch(
        bytes32 _watchId,
        address _buyer
    ) public returns (bytes32) {
        require(
            watches[uint256(_watchId)].isListed,
            "Watch is not listed for sale"
        );
        require(
            watches[uint256(_watchId)].price > 0,
            "Price is not set for the watch"
        );
        require(
            usdcToken.balanceOf(_buyer) >= watches[uint256(_watchId)].price,
            "Insufficient balance"
        );
        usdcToken.transferFrom(
            _buyer,
            ownerOf(uint256(_watchId)),
            watches[uint256(_watchId)].price
        );
        _transfer(ownerOf(uint256(_watchId)), _buyer, uint256(_watchId));
        watches[uint256(_watchId)].isListed = false;
        emit WatchBought(_watchId, _buyer);
        return _watchId;
    }

    function burnWatch(bytes32 _watchId) public returns (bytes32) {
        require(
            ownerOf(uint256(_watchId)) == msg.sender,
            "User is not the owner of the watch"
        );
        _burn(uint256(_watchId));
        emit WatchBurned(_watchId);
        return _watchId;
    }
}
