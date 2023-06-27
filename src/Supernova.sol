// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

/**
 * アニメ メタバース 超新星
 * Anime Metaverse SUPERNOVA
 */

///@author WhiteOakKong

import { Ownable } from "openzeppelin/contracts/access/Ownable.sol";
import { ECDSA } from "openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { Strings } from "openzeppelin/contracts/utils/Strings.sol";
import { ERC721A } from "ERC721A/contracts/ERC721A.sol";
import { IERC721 } from "openzeppelin/contracts/token/ERC721/IERC721.sol";
import { DefaultOperatorFilterer } from "operator-filter-registry/src/DefaultOperatorFilterer.sol";

interface IBurntSouls {
    function resurect(address to, uint256 tokenId) external;
}

contract SuperNova is ERC721A, Ownable, DefaultOperatorFilterer {
    using Strings for uint256;
    using ECDSA for bytes32;

    // ============ 保管所 ============

    IERC721 public immutable soulMates;
    IBurntSouls public immutable burntSouls;

    uint256 private constant LEGENDARY_COUNT = 28;

    bool public publicMinting;

    address private constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    address public signer;
    address public relayer;

    string public baseURI;
    string public uriExtension = ".json";

    mapping(address => bool) public treasuryWallets;

    event Supernova(uint256 tokenId, uint256[] burntTokens, uint256 burntTotal, string character, uint256 hype);
    event BaseURIUpdated(string baseURI);
    event ExtensionUpdated(string extension);
    event SignerUpdated(address signer);
    event RelayerUpdated(address relayer);

    error MintingClosed();
    error BurnQuantityInvalid();
    error InvalidSignature();
    error LegendaryCountExceeded();
    error InvalidLegendaryQuantity();
    error MinterNotRelayer();
    error NotTreasuryWallet();
    error ZeroAddress();

    // ============ コンストラクタ ============

    constructor(
        address[] memory legendaryAddresses,
        address _burntSouls,
        address _soulMates,
        address _signer,
        address _relayer
    )
        ERC721A("Supernova", "AMSNOVA")
    {
        mintLegendary(legendaryAddresses);
        soulMates = IERC721(_soulMates);
        burntSouls = IBurntSouls(_burntSouls);
        signer = _signer;
        relayer = _relayer;
    }

    // ============ ミント関数 ============

    ///@notice Main function to mint a Supernova. Uses ECDSA to verify the mint details, and emits custom event for
    /// indexing.
    ///@param burntsouls - array of soulmate token ids
    ///@param character - character name: Rikka, Minami, Saki, Kyoko, Kumi, Male, or Random
    ///@param signature - signature for ECDSA recovery
    ///@param hype - quantity of hype from all burnt tokens
    function mintSupernova(
        uint256[] calldata burntsouls,
        bytes memory signature,
        string memory character,
        uint256 hype
    )
        external
    {
        if (!publicMinting) revert MintingClosed();
        if (burntsouls.length == 0 || burntsouls.length > 5) revert BurnQuantityInvalid();
        if (!_isValidSignature(signature, burntsouls, character, hype)) revert InvalidSignature();
        for (uint256 i = 0; i < burntsouls.length; i++) {
            soulMates.transferFrom(msg.sender, BURN_ADDRESS, burntsouls[i]);
            burntSouls.resurect(msg.sender, burntsouls[i]);
        }
        _mint(msg.sender, 1);
        emit Supernova(_totalMinted(), burntsouls, burntsouls.length, character, hype);
    }

    ///@notice Function to mint 1/1 Supernovas. These tokens are not mintable by the public, and are to be minted during
    /// contract deployment.
    ///@dev Mint all 28 Legendaries at once. All tokens mint sequentially, starting at 1. No event emission as these are
    /// preassigned. Mint during contract deployment.
    ///@param to - array of addresses to mint to
    function mintLegendary(address[] memory to) internal {
        if (to.length != LEGENDARY_COUNT) revert InvalidLegendaryQuantity();
        if (_totalMinted() >= LEGENDARY_COUNT) revert LegendaryCountExceeded();
        for (uint256 i; i < to.length; i++) {
            _mint(to[i], 1);
        }
    }

    ///@notice Secondary function to allow minting of male tokens.
    ///@dev Only the registered relayer can use this function.
    ///@param recipient - address to mint token to.
    function mintMale(address recipient) external {
        if (msg.sender != relayer) revert MinterNotRelayer();
        uint256[] memory emptyArray = new uint256[](0);
        _mint(recipient, 1);
        emit Supernova(_totalMinted(), emptyArray, 0, "Male", 0);
    }

    // ============ 効用 ============

    ///@notice Function to return tokenURI.
    ///@param _tokenId - tokenId to be returned.
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), "Token does not exist.");
        return string(abi.encodePacked(baseURI, Strings.toString(_tokenId), uriExtension));
    }

    //revert if token does not exist

    ///@notice internal signature validation function.
    ///@param signature - signature for ECDSA recovery.
    ///@param burntTokens - array of soulmate token ids.
    ///@param character - character name: Rikka, Minami, Saki, Kyoko, Kumi, or Random
    ///@param hype - quantity of hype from all burnt tokens.
    function _isValidSignature(
        bytes memory signature,
        uint256[] calldata burntTokens,
        string memory character,
        uint256 hype
    )
        internal
        view
        returns (bool)
    {
        bytes32 data = keccak256(abi.encodePacked(burntTokens, "_", character, "_", hype));
        return signer == data.toEthSignedMessageHash().recover(signature);
    }

    ///@notice Overriding the default tokenID start to 1.
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    // ============ 制限付きアクセス ============

    ///@notice Team restricted function to mint a Supernova. Uses ECDSA to verify the mint details, and emits custom
    /// event for indexing.
    ///@dev Setting this up to allow early minting for the team.
    ///@param burntsouls - array of soulmate token ids
    ///@param character - character name: Rikka, Minami, Saki, Kyoko, Kumi, Male, or Random
    ///@param signature - signature for ECDSA recovery
    ///@param hype - quantity of hype from all burnt tokens
    function teamSupernovaMint(
        uint256[] calldata burntsouls,
        bytes memory signature,
        string memory character,
        uint256 hype
    )
        external
    {
        if (!treasuryWallets[msg.sender]) revert NotTreasuryWallet();
        if (burntsouls.length == 0 || burntsouls.length > 5) revert BurnQuantityInvalid();
        if (!_isValidSignature(signature, burntsouls, character, hype)) revert InvalidSignature();
        for (uint256 i = 0; i < burntsouls.length; i++) {
            soulMates.transferFrom(msg.sender, BURN_ADDRESS, burntsouls[i]);
            burntSouls.resurect(msg.sender, burntsouls[i]);
        }
        _mint(msg.sender, 1);
        emit Supernova(_totalMinted(), burntsouls, burntsouls.length, character, hype);
    }

    //TEST CONDITIONS
    //only mint if wallet is WL
    //only mint if public minting is enabled
    //only mint if burn quantity is between 1 and 5
    //only mint if signature is valid
    //transfer all burnt tokens to burn address
    //revert if tokens are not owned by msg.sender
    //revert if tokens are not approved for transfer
    //mint burnt souls to msg.sender
    //mint one supernova to msg.sender
    //emit Supernova event

    ///@notice Function to set the relayer address.
    ///@param _relayer - address of the relayer.
    function updateRelayer(address _relayer) external onlyOwner {
        if (_relayer == address(0)) revert ZeroAddress();
        relayer = _relayer;
        emit RelayerUpdated(_relayer);
    }

    ///@notice Function to set the signer address.
    ///@param _signer - address of the signer.
    function updateSigner(address _signer) external onlyOwner {
        if (_signer == address(0)) revert ZeroAddress();
        signer = _signer;
        emit SignerUpdated(_signer);
    }

    ///@notice Function to set the uri extension.
    ///@param _ext - uri extension.
    function updateExtension(string memory _ext) external onlyOwner {
        uriExtension = _ext;
        emit ExtensionUpdated(_ext);
    }

    //set uriExtension to _ext
    //emit ExtensionUpdated event
    //revert if msg.sender is not owner

    ///@notice Function to set the baseURI for the contract.
    ///@param baseURI_ - baseURI for the contract.
    function setBaseURI(string memory baseURI_) external onlyOwner {
        baseURI = baseURI_;
        emit BaseURIUpdated(baseURI_);
    }

    ///@notice Function to toggle public minting of Supernovas.
    function togglePublic() external onlyOwner {
        publicMinting = !publicMinting;
    }

    //set publicMinting to !publicMinting
    //revert if msg.sender is not owner

    ///@notice Function to add a treasury wallet. Access control for team mint.
    function addTreasuryWallet(address _wallet) external onlyOwner {
        treasuryWallets[_wallet] = true;
    }

    //set treasuryWallets[_wallet] to true
    //revert if msg.sender is not owner

    ///@notice Function to withdraw all funds from the contract. Should not be necessary, but just in case.
    function withdraw() external onlyOwner {
        (bool success,) = payable(msg.sender).call{ value: address(this).balance }("");
        require(success, "Transfer failed.");
    }

    // ============ ファックオープンシー ============

    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId) public payable override onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    )
        public
        payable
        override
        onlyAllowedOperator(from)
    {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    )
        public
        payable
        override
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    )
        public
        payable
        override
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, data);
    }
}
