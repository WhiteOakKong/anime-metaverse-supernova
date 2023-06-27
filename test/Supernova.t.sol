//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import { SuperNova } from "../src/SuperNova.sol";
import { BurntSouls } from "../src/BurntSouls.sol";
import { MockSoulMate } from "../src/Mocks/MockSoul.sol";
import { ECDSA } from "openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SupernovaTest is PRBTest, StdCheats {
    using ECDSA for bytes32;

    SuperNova superNova;
    BurntSouls burntSouls;
    MockSoulMate mockSoulMate;

    address public relayer = makeAddr("relayer");
    address public signer;
    uint256 public signerKey;

    address private constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    address[] public accts = new address[](5);

    event Supernova(uint256 tokenId, uint256[] burntTokens, uint256 burntTotal, string character, uint256 hype);
    event BaseURIUpdated(string baseURI);
    event ExtensionUpdated(string extension);
    event SignerUpdated(address signer);
    event RelayerUpdated(address relayer);

    function setUp() public {
        (signer, signerKey) = makeAddrAndKey("signer");

        for (uint256 i = 0; i < 5; i++) {
            accts[i] = vm.addr(i + 999);
            vm.label(accts[i], string(abi.encodePacked("ACCOUNT ", i)));
        }
        burntSouls = new BurntSouls();
        mockSoulMate = new MockSoulMate();
        address[] memory _legendaryArray = new address[](28);
        for (uint256 i = 0; i < 28; i++) {
            _legendaryArray[i] = vm.addr(i + 1);
        }
        superNova = new SuperNova(_legendaryArray, address(burntSouls), address(mockSoulMate), signer, relayer);
        for (uint256 i = 0; i < 28; i++) {
            assertEq(superNova.balanceOf(_legendaryArray[i]), 1);
        }
        burntSouls.setSupernova(address(superNova));
    }

    function _generateSignature(
        uint256[] memory _tokens,
        string memory _character,
        uint256 _hype
    )
        internal
        view
        returns (bytes memory signature)
    {
        bytes32 data = keccak256(abi.encodePacked(_tokens, "_", _character, "_", _hype)).toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerKey, data);
        signature = abi.encodePacked(r, s, v);
    }

    //Function mintSupernova - TEST CONDITIONS
    //✅ only mint if public minting is enabled
    //✅ only mint if burn quantity is between 1 and 5
    //✅ only mint if signature is valid
    //✅ transfer all burnt tokens to burn address
    //✅ revert if tokens are not owned by msg.sender
    //✅ revert if tokens are not approved for transfer
    //✅ mint burnt souls to msg.sender
    //✅ mint one supernova to msg.sender
    //✅ emit Supernova event

    function test_mintSupernova_success_burn1() public {
        mockSoulMate.mint(accts[0], 1);
        uint256[] memory _tokens = new uint256[](1);
        _tokens[0] = 0;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        vm.expectEmit(false, false, false, true);
        emit Supernova(superNova.totalSupply() + 1, _tokens, _tokens.length, "test", 1);
        superNova.mintSupernova(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 1);
        for (uint256 i = 0; i < _tokens.length; i++) {
            assertEq(mockSoulMate.ownerOf(_tokens[i]), BURN_ADDRESS);
            assertEq(burntSouls.ownerOf(_tokens[i]), accts[0]);
        }
        vm.stopPrank();
    }

    function test_mintSupernova_success_burn2() public {
        mockSoulMate.mint(accts[0], 2);
        uint256[] memory _tokens = new uint256[](2);
        _tokens[0] = 0;
        _tokens[1] = 1;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        superNova.mintSupernova(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 1);
        for (uint256 i = 0; i < _tokens.length; i++) {
            assertEq(mockSoulMate.ownerOf(_tokens[i]), BURN_ADDRESS);
            assertEq(burntSouls.ownerOf(_tokens[i]), accts[0]);
        }
        vm.stopPrank();
    }

    function test_mintSupernova_success_burn3() public {
        mockSoulMate.mint(accts[0], 3);
        uint256[] memory _tokens = new uint256[](3);
        _tokens[0] = 0;
        _tokens[1] = 1;
        _tokens[2] = 2;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        superNova.mintSupernova(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 1);
        for (uint256 i = 0; i < _tokens.length; i++) {
            assertEq(mockSoulMate.ownerOf(_tokens[i]), BURN_ADDRESS);
            assertEq(burntSouls.ownerOf(_tokens[i]), accts[0]);
        }
        vm.stopPrank();
    }

    function test_mintSupernova_success_burn4() public {
        mockSoulMate.mint(accts[0], 4);
        uint256[] memory _tokens = new uint256[](4);
        _tokens[0] = 0;
        _tokens[1] = 1;
        _tokens[2] = 2;
        _tokens[3] = 3;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        superNova.mintSupernova(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 1);
        for (uint256 i = 0; i < _tokens.length; i++) {
            assertEq(mockSoulMate.ownerOf(_tokens[i]), BURN_ADDRESS);
            assertEq(burntSouls.ownerOf(_tokens[i]), accts[0]);
        }
        vm.stopPrank();
    }

    function test_mintSupernova_success_burn5() public {
        mockSoulMate.mint(accts[0], 5);
        uint256[] memory _tokens = new uint256[](5);
        _tokens[0] = 0;
        _tokens[1] = 1;
        _tokens[2] = 2;
        _tokens[3] = 3;
        _tokens[4] = 4;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        superNova.mintSupernova(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 1);
        for (uint256 i = 0; i < _tokens.length; i++) {
            assertEq(mockSoulMate.ownerOf(_tokens[i]), BURN_ADDRESS);
            assertEq(burntSouls.ownerOf(_tokens[i]), accts[0]);
        }
        vm.stopPrank();
    }

    function test_mintSupernova_fail_burn0() public {
        uint256[] memory _tokens = new uint256[](0);
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        vm.expectRevert(bytes4(keccak256("BurnQuantityInvalid()")));
        superNova.mintSupernova(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 0);
        vm.stopPrank();
    }

    function test_mintSupernova_fail_burn6() public {
        mockSoulMate.mint(accts[0], 6);
        uint256[] memory _tokens = new uint256[](6);
        _tokens[0] = 0;
        _tokens[1] = 1;
        _tokens[2] = 2;
        _tokens[3] = 3;
        _tokens[4] = 4;
        _tokens[5] = 5;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        vm.expectRevert(bytes4(keccak256("BurnQuantityInvalid()")));
        superNova.mintSupernova(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 0);
        vm.stopPrank();
    }

    function test_mintSupernova_fail_publicNotEnabled() public {
        mockSoulMate.mint(accts[0], 1);
        uint256[] memory _tokens = new uint256[](1);
        _tokens[0] = 0;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        vm.expectRevert(bytes4(keccak256("MintingClosed()")));
        superNova.mintSupernova(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 0);
        vm.stopPrank();
    }

    function test_mintSupernova_fail_invalidSignatureWithWrongArguments() public {
        mockSoulMate.mint(accts[0], 1);
        uint256[] memory _tokens = new uint256[](1);
        _tokens[0] = 0;
        bytes memory signature = _generateSignature(_tokens, "test", 2);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        vm.expectRevert(bytes4(keccak256("InvalidSignature()")));
        superNova.mintSupernova(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 0);
        vm.stopPrank();
    }

    function test_mintSupernova_fail_invalidSignatureWrongSigner() public {
        mockSoulMate.mint(accts[0], 1);
        uint256[] memory _tokens = new uint256[](1);
        _tokens[0] = 0;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.updateSigner(accts[1]);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        vm.expectRevert(bytes4(keccak256("InvalidSignature()")));
        superNova.mintSupernova(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 0);
        vm.stopPrank();
    }

    function test_mintSupernova_fail_msgSenderDoesntOwnTokens() public {
        mockSoulMate.mint(accts[0], 1);
        uint256[] memory _tokens = new uint256[](1);
        _tokens[0] = 0;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        vm.stopPrank();
        vm.startPrank(accts[1]);
        vm.expectRevert(bytes4(keccak256("TransferFromIncorrectOwner()")));
        superNova.mintSupernova(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[1]), 0);
        vm.stopPrank();
    }

    function test_mintSupernova_fail_tokensNotApproved() public {
        mockSoulMate.mint(accts[0], 1);
        uint256[] memory _tokens = new uint256[](1);
        _tokens[0] = 0;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        vm.expectRevert(bytes4(keccak256("TransferCallerNotOwnerNorApproved()")));
        superNova.mintSupernova(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 0);
        vm.stopPrank();
    }

    // Function mintMale - TEST CONDITIONS
    //✅ revert if msg.sender != relayer
    //✅ mint one supernova to recipient
    //✅ emit Supernova event

    function test_mintMale_success_mintWithRelayer() public {
        vm.startPrank(relayer);
        vm.expectEmit(false, false, false, true);
        uint256[] memory _tokens = new uint256[](0);
        emit Supernova(29, _tokens, 0, "Male", 0);
        superNova.mintMale(accts[0]);
        assertEq(superNova.balanceOf(accts[0]), 1);
    }

    function test_mintMale_fail_mintWithNonRelayer() public {
        vm.startPrank(accts[0]);
        vm.expectRevert(bytes4(keccak256("MinterNotRelayer()")));
        superNova.mintMale(accts[0]);
        assertEq(superNova.balanceOf(accts[0]), 0);
    }

    // Function updateRelayer - TEST CONDITIONS
    //✅ revert if msg.sender is not owner
    //✅ revert if _relayer is 0 address
    //✅ set relayer to _relayer
    //✅ emit RelayerUpdated event

    function test_updateRelayer_success_updateWithOwner() public {
        vm.expectEmit(false, false, false, true);
        emit RelayerUpdated(accts[0]);
        superNova.updateRelayer(accts[0]);
        assertEq(superNova.relayer(), accts[0]);
    }

    function test_updateRelayer_fail_updateWithWrongAccount() public {
        vm.startPrank(accts[1]);
        vm.expectRevert("Ownable: caller is not the owner");
        superNova.updateRelayer(accts[0]);
        assertEq(superNova.relayer(), relayer);
    }

    function test_updateRelayer_fail_updateToZeroAddress() public {
        vm.expectRevert(bytes4(keccak256("ZeroAddress()")));
        superNova.updateRelayer(address(0));
        assertEq(superNova.relayer(), relayer);
    }

    // Function updateSigner - TEST CONDITIONS
    //✅ revert if _signer is 0 address
    //✅ set signer to _signer
    //✅ emit SignerUpdated event
    //✅ revert if msg.sender is not owner

    function test_updateSigner_success_updateWithOwner() public {
        vm.expectEmit(false, false, false, true);
        emit SignerUpdated(accts[0]);
        superNova.updateSigner(accts[0]);
        assertEq(superNova.signer(), accts[0]);
    }

    function test_updateSigner_fail_updateWithWrongAccount() public {
        vm.startPrank(accts[1]);
        vm.expectRevert("Ownable: caller is not the owner");
        superNova.updateSigner(accts[0]);
        assertEq(superNova.signer(), signer);
    }

    function test_updateSigner_fail_updateToZeroAddress() public {
        vm.expectRevert(bytes4(keccak256("ZeroAddress()")));
        superNova.updateSigner(address(0));
        assertEq(superNova.signer(), signer);
    }

    // Function updateExtension - TEST CONDITIONS
    //set uriExtension to _ext
    //emit ExtensionUpdated event
    //revert if msg.sender is not owner

    function test_updateExtension_success_updateWithOwner() public {
        vm.expectEmit(false, false, false, true);
        emit ExtensionUpdated("test");
        superNova.updateExtension("test");
        assertEq(superNova.uriExtension(), "test");
    }

    function test_updateExtension_fail_updateWithWrongAccount() public {
        vm.startPrank(accts[1]);
        vm.expectRevert("Ownable: caller is not the owner");
        superNova.updateExtension("test");
        assertEq(superNova.uriExtension(), ".json");
    }

    // Function updateBaseURI - TEST CONDITIONS
    //set baseURI to baseURI_
    //emit BaseURIUpdated event
    //revert if msg.sender is not owner

    function test_setBaseURI_success_updateWithOwner() public {
        vm.expectEmit(false, false, false, true);
        emit BaseURIUpdated("test");
        superNova.setBaseURI("test");
        assertEq(superNova.baseURI(), "test");
    }

    function test_setBaseURI_fail_updateWithWrongAccount() public {
        vm.startPrank(accts[1]);
        vm.expectRevert("Ownable: caller is not the owner");
        superNova.setBaseURI("test");
        assertEq(superNova.baseURI(), "");
    }

    // Function togglePublic - TEST CONDITIONS
    //set publicMinting to !publicMinting
    //revert if msg.sender is not owner

    function test_togglePublic_success_updateWithOwner() public {
        superNova.togglePublic();
        assertEq(superNova.publicMinting(), true);
    }

    function test_togglePublic_fail_updateWithWrongAccount() public {
        vm.startPrank(accts[1]);
        vm.expectRevert("Ownable: caller is not the owner");
        superNova.togglePublic();
        assertEq(superNova.publicMinting(), false);
    }

    // Function addTreasuryWallets - TEST CONDITIONS
    //set treasuryWallets[_wallet] to true
    //revert if msg.sender is not owner

    function test_addTreasuryWallet_success_updateWithOwner() public {
        for (uint256 i = 0; i < accts.length; i++) {
            superNova.addTreasuryWallet(accts[i]);
            assertEq(superNova.treasuryWallets(accts[i]), true);
        }
    }

    function test_addTreasuryWallet_fail_updateWithWrongAccount() public {
        vm.startPrank(accts[1]);
        vm.expectRevert("Ownable: caller is not the owner");
        superNova.addTreasuryWallet(accts[0]);
        assertEq(superNova.treasuryWallets(accts[0]), false);
    }

    // Function withdraw - TEST CONDITIONS
    //revert if msg.sender is not owner
    //transfer all funds from contract to msg.sender

    function test_withdraw_success_withdrawOwner() public {
        uint256 beforeBalance = address(this).balance;
        vm.deal(address(superNova), 1 ether);
        uint256 contractBalance = address(superNova).balance;
        superNova.withdraw();
        assertEq(address(this).balance, beforeBalance + contractBalance);
        assertEq(address(superNova).balance, 0);
    }

    function test_withdraw_fail_withdrawWithWrongAccount() public {
        vm.startPrank(accts[1]);
        uint256 beforeBalance = accts[1].balance;
        vm.deal(address(superNova), 1 ether);
        uint256 contractBalance = address(superNova).balance;
        vm.expectRevert("Ownable: caller is not the owner");
        superNova.withdraw();
        assertEq(address(superNova).balance, contractBalance);
        assertEq(accts[1].balance, beforeBalance);
    }

    function test_withdraw_fail_transferUnsuccessful() public {
        superNova.transferOwnership(address(burntSouls));
        vm.deal(address(superNova), 1 ether);
        vm.startPrank(address(burntSouls));
        vm.expectRevert("Transfer failed.");
        superNova.withdraw();
        assertEq(address(superNova).balance, 1 ether);
        assertEq(address(burntSouls).balance, 0);
    }

    function test_tokenURI_fail_callWithUnmintedTokenID() public {
        vm.expectRevert("Token does not exist.");
        superNova.tokenURI(30);
    }

    function test_tokenURI_success_callWithMintedToken() public {
        superNova.setBaseURI("test.com/");
        string memory uri = superNova.tokenURI(1);
        assertEq(uri, "test.com/1.json");
    }

    //Function teamSupernovaMint - TEST CONDITIONS
    //✅ only mint if public minting is enabled
    //✅ only mint if burn quantity is between 1 and 5
    //✅ only mint if signature is valid
    //✅ transfer all burnt tokens to burn address
    //✅ revert if tokens are not owned by msg.sender
    //✅ revert if tokens are not approved for transfer
    //✅ mint burnt souls to msg.sender
    //✅ mint one supernova to msg.sender
    //✅ emit Supernova event

    function test_teamSupernovaMint_success_burn1() public {
        mockSoulMate.mint(accts[0], 1);
        superNova.addTreasuryWallet(accts[0]);
        uint256[] memory _tokens = new uint256[](1);
        _tokens[0] = 0;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        vm.expectEmit(false, false, false, true);
        emit Supernova(superNova.totalSupply() + 1, _tokens, _tokens.length, "test", 1);
        superNova.teamSupernovaMint(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 1);
        for (uint256 i = 0; i < _tokens.length; i++) {
            assertEq(mockSoulMate.ownerOf(_tokens[i]), BURN_ADDRESS);
            assertEq(burntSouls.ownerOf(_tokens[i]), accts[0]);
        }
        vm.stopPrank();
    }

    function test_teamSupernovaMint_success_burn2() public {
        mockSoulMate.mint(accts[0], 2);
        superNova.addTreasuryWallet(accts[0]);
        uint256[] memory _tokens = new uint256[](2);
        _tokens[0] = 0;
        _tokens[1] = 1;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        superNova.teamSupernovaMint(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 1);
        for (uint256 i = 0; i < _tokens.length; i++) {
            assertEq(mockSoulMate.ownerOf(_tokens[i]), BURN_ADDRESS);
            assertEq(burntSouls.ownerOf(_tokens[i]), accts[0]);
        }
        vm.stopPrank();
    }

    function test_teamSupernovaMint_success_burn3() public {
        mockSoulMate.mint(accts[0], 3);
        superNova.addTreasuryWallet(accts[0]);
        uint256[] memory _tokens = new uint256[](3);
        _tokens[0] = 0;
        _tokens[1] = 1;
        _tokens[2] = 2;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        superNova.teamSupernovaMint(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 1);
        for (uint256 i = 0; i < _tokens.length; i++) {
            assertEq(mockSoulMate.ownerOf(_tokens[i]), BURN_ADDRESS);
            assertEq(burntSouls.ownerOf(_tokens[i]), accts[0]);
        }
        vm.stopPrank();
    }

    function test_teamSupernovaMint_success_burn4() public {
        mockSoulMate.mint(accts[0], 4);
        superNova.addTreasuryWallet(accts[0]);
        uint256[] memory _tokens = new uint256[](4);
        _tokens[0] = 0;
        _tokens[1] = 1;
        _tokens[2] = 2;
        _tokens[3] = 3;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        superNova.teamSupernovaMint(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 1);
        for (uint256 i = 0; i < _tokens.length; i++) {
            assertEq(mockSoulMate.ownerOf(_tokens[i]), BURN_ADDRESS);
            assertEq(burntSouls.ownerOf(_tokens[i]), accts[0]);
        }
        vm.stopPrank();
    }

    function test_teamSupernovaMint_success_burn5() public {
        mockSoulMate.mint(accts[0], 5);
        superNova.addTreasuryWallet(accts[0]);
        uint256[] memory _tokens = new uint256[](5);
        _tokens[0] = 0;
        _tokens[1] = 1;
        _tokens[2] = 2;
        _tokens[3] = 3;
        _tokens[4] = 4;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        superNova.teamSupernovaMint(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 1);
        for (uint256 i = 0; i < _tokens.length; i++) {
            assertEq(mockSoulMate.ownerOf(_tokens[i]), BURN_ADDRESS);
            assertEq(burntSouls.ownerOf(_tokens[i]), accts[0]);
        }
        vm.stopPrank();
    }

    function test_teamSupernovaMint_fail_burn0() public {
        superNova.addTreasuryWallet(accts[0]);
        uint256[] memory _tokens = new uint256[](0);
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        vm.expectRevert(bytes4(keccak256("BurnQuantityInvalid()")));
        superNova.teamSupernovaMint(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 0);
        vm.stopPrank();
    }

    function test_teamSupernovaMint_fail_burn6() public {
        superNova.addTreasuryWallet(accts[0]);
        mockSoulMate.mint(accts[0], 6);
        uint256[] memory _tokens = new uint256[](6);
        _tokens[0] = 0;
        _tokens[1] = 1;
        _tokens[2] = 2;
        _tokens[3] = 3;
        _tokens[4] = 4;
        _tokens[5] = 5;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        vm.expectRevert(bytes4(keccak256("BurnQuantityInvalid()")));
        superNova.teamSupernovaMint(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 0);
        vm.stopPrank();
    }

    function test_teamSupernovaMint_success_publicNotEnabled() public {
        superNova.addTreasuryWallet(accts[0]);
        mockSoulMate.mint(accts[0], 1);
        uint256[] memory _tokens = new uint256[](1);
        _tokens[0] = 0;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        superNova.teamSupernovaMint(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 1);
        vm.stopPrank();
    }

    function test_teamSupernovaMint_fail_invalidSignatureWithWrongArguments() public {
        superNova.addTreasuryWallet(accts[0]);
        mockSoulMate.mint(accts[0], 1);
        uint256[] memory _tokens = new uint256[](1);
        _tokens[0] = 0;
        bytes memory signature = _generateSignature(_tokens, "test", 2);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        vm.expectRevert(bytes4(keccak256("InvalidSignature()")));
        superNova.teamSupernovaMint(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 0);
        vm.stopPrank();
    }

    function test_teamSupernovaMint_fail_invalidSignatureWrongSigner() public {
        superNova.addTreasuryWallet(accts[0]);
        mockSoulMate.mint(accts[0], 1);
        uint256[] memory _tokens = new uint256[](1);
        _tokens[0] = 0;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.updateSigner(accts[1]);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        vm.expectRevert(bytes4(keccak256("InvalidSignature()")));
        superNova.teamSupernovaMint(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 0);
        vm.stopPrank();
    }

    function test_teamSupernovaMint_fail_msgSenderDoesntOwnTokens() public {
        superNova.addTreasuryWallet(accts[1]);
        mockSoulMate.mint(accts[0], 1);
        uint256[] memory _tokens = new uint256[](1);
        _tokens[0] = 0;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        vm.stopPrank();
        vm.startPrank(accts[1]);
        vm.expectRevert(bytes4(keccak256("TransferFromIncorrectOwner()")));
        superNova.teamSupernovaMint(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[1]), 0);
        vm.stopPrank();
    }

    function test_teamSupernovaMint_fail_tokensNotApproved() public {
        superNova.addTreasuryWallet(accts[0]);
        mockSoulMate.mint(accts[0], 1);
        uint256[] memory _tokens = new uint256[](1);
        _tokens[0] = 0;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        vm.expectRevert(bytes4(keccak256("TransferCallerNotOwnerNorApproved()")));
        superNova.teamSupernovaMint(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 0);
        vm.stopPrank();
    }

    function test_teamSupernovaMint_fail_NotTreasuryWallet() public {
        mockSoulMate.mint(accts[0], 1);
        uint256[] memory _tokens = new uint256[](1);
        _tokens[0] = 0;
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNova.togglePublic();
        vm.startPrank(accts[0]);
        mockSoulMate.setApprovalForAll(address(superNova), true);
        vm.expectRevert(bytes4(keccak256("NotTreasuryWallet()")));
        superNova.teamSupernovaMint(_tokens, signature, "test", 1);
        assertEq(superNova.balanceOf(accts[0]), 0);
        vm.stopPrank();
    }

    function test__isValidSignature_returnTrue() public {
        address[] memory _legendaryArray = new address[](28);
        for (uint256 i = 0; i < 28; i++) {
            _legendaryArray[i] = vm.addr(i + 1);
        }
        SuperNovaHarness superNovaHarness = new SuperNovaHarness(
            _legendaryArray,
            address(burntSouls),
            address(mockSoulMate),
            signer,
            relayer
        );
        uint256[] memory _tokens = new uint256[](0);
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        assertEq(superNovaHarness.exposed__isValidSignature(signature, _tokens, "test", 1), true);
    }

    function test__isValidSignature_returnFalse() public {
        address[] memory _legendaryArray = new address[](28);
        for (uint256 i = 0; i < 28; i++) {
            _legendaryArray[i] = vm.addr(i + 1);
        }
        SuperNovaHarness superNovaHarness = new SuperNovaHarness(
            _legendaryArray,
            address(burntSouls),
            address(mockSoulMate),
            signer,
            relayer
        );
        uint256[] memory _tokens = new uint256[](0);
        bytes memory signature = _generateSignature(_tokens, "test", 1);
        superNovaHarness.updateSigner(relayer);
        assertEq(superNovaHarness.exposed__isValidSignature(signature, _tokens, "test", 1), false);
    }

    function test_togglePublic_success_callWithOwner() public {
        superNova.togglePublic();
        assertEq(superNova.publicMinting(), true);
    }

    function test_togglePublic_fail_callWithNonOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.startPrank(accts[0]);
        superNova.togglePublic();
        vm.stopPrank();
        assertEq(superNova.publicMinting(), false);
    }

    function test_mintLegendary_fail_callAfterConstruction() public {
        address[] memory _legendaryArray = new address[](28);
        for (uint256 i = 0; i < 28; i++) {
            _legendaryArray[i] = vm.addr(i + 1);
        }
        SuperNovaHarness superNovaHarness = new SuperNovaHarness(
            _legendaryArray,
            address(burntSouls),
            address(mockSoulMate),
            signer,
            relayer
        );
        vm.expectRevert(bytes4(keccak256("LegendaryCountExceeded()")));
        superNovaHarness.exposed_mintLegendary(_legendaryArray);
        assertEq(superNovaHarness.totalSupply(), 28);
    }

    function test_mintLegendary_fail_incorrectArrayLength() public {
        address[] memory _legendaryArray = new address[](28);
        for (uint256 i = 0; i < 28; i++) {
            _legendaryArray[i] = vm.addr(i + 1);
        }
        SuperNovaHarness superNovaHarness = new SuperNovaHarness(
            _legendaryArray,
            address(burntSouls),
            address(mockSoulMate),
            signer,
            relayer
        );
        address[] memory _tokens = new address[](27);
        for (uint256 i = 0; i < 27; i++) {
            _tokens[i] = vm.addr(i + 1);
        }
        vm.expectRevert(bytes4(keccak256("InvalidLegendaryQuantity()")));
        superNovaHarness.exposed_mintLegendary(_tokens);
        assertEq(superNovaHarness.totalSupply(), 28);
    }

    receive() external payable { }
}

contract SuperNovaHarness is SuperNova {
    constructor(
        address[] memory _legendaryArray,
        address _burntSouls,
        address _mockSoulMate,
        address _signer,
        address _relayer
    )
        SuperNova(_legendaryArray, _burntSouls, _mockSoulMate, _signer, _relayer)
    { }

    function exposed__isValidSignature(
        bytes memory _signature,
        uint256[] calldata _tokens,
        string memory _character,
        uint256 _hype
    )
        public
        view
        returns (bool)
    {
        return _isValidSignature(_signature, _tokens, _character, _hype);
    }

    function exposed_mintLegendary(address[] memory to) public {
        mintLegendary(to);
    }
}
