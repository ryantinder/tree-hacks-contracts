// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { IdentityProvider } from "src/IdentityProvider.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract IdentityProviderTest is PRBTest, StdCheats {
    address me = 0xb9413c6FDA8Eac23E8F2cB2cc62D90881aBdD77d;
    /// @dev An optional function invoked before each test case is run
    IdentityProvider identityProvider;
    address alice = address(14);
    address bob = address(15);
    string RPC_URL = vm.envString("OPTIMISM");
    function setUp() public {
        // solhint-disable-previous-line no-empty-blocks
        vm.createSelectFork(RPC_URL);
        identityProvider = new IdentityProvider();
    }

    function testMints() public  {
        hoax(alice, alice);
        identityProvider.mint();
        
        hoax(bob, bob);
        identityProvider.mint();

        assertEq(identityProvider.balanceOf(alice), 1);
        assertEq(identityProvider.balanceOf(bob), 1);
        assertEq(identityProvider.ownerOf(0), alice);
        assertEq(identityProvider.ownerOf(1), bob);
    }

    function testMultipleMints() public {
        hoax(alice, alice);
        identityProvider.mint();
        hoax(alice, alice);
        vm.expectRevert("You have already minted an identity");
        identityProvider.mint();
    }

    function testCannotTransfer() public {
        startHoax(alice, alice);
        identityProvider.mint();
        vm.expectRevert("You cannot transfer an identity");
        identityProvider.transferFrom(alice, bob, 0);
        vm.expectRevert("You cannot transfer an identity");
        identityProvider.safeTransferFrom(alice, bob, 0);
        vm.expectRevert("You cannot transfer an identity");
        identityProvider.safeTransferFrom(alice, bob, 0, bytes("0x0"));
    }

    
}
