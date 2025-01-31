// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/MyToken.sol";
import "../lib/forge-std/src/Test.sol";

contract MyTokenTest is Test {

    MyToken public myToken;    

    function setUp() public {
        string memory _name = "Lypes";
        string memory _symbol = "lyp";
        uint8 _decimals = 2; 
        uint256 initialSupply = 10;

        myToken = new MyToken(_name, _symbol, _decimals, initialSupply);
    }

    // Teste Equivalência

    function testApproveValid() public {
        address spender = address(0x01);
        uint256 amount = 5;

        assert(myToken.approve(spender, amount));
        assertEq(myToken.allowance(address(this), spender), amount);
    }

    function testApproveInvalid() public {
        address spender = address(0x01);
        uint256 amount = myToken.balanceOf(address(this)) + 1; 
        vm.expectRevert();
        myToken.approve(spender, amount);
    }

    function testTranferValid() public {
        address recipient = address(0x01);
        uint256 amount = 10;

        myToken.transfer(recipient, amount);

        assert(myToken.balanceOf(address(this)) < myToken.balanceOf(recipient));
    }

    function testTranferInvalid() public {
        address recipient = address(0x01);
        uint256 amount =  myToken.balanceOf(address(this)) + 5;
        
        vm.expectRevert("Insufficient balance");
        myToken.transfer(recipient, amount);
    }

    function testTranferFromValid() public {
        address owner = address(this);
        address spender = address(0x01);
        address recipient = address(0x02);
        uint256 amount = 5;

        
        myToken.approve(spender, amount);

        vm.prank(spender); // simula transação feita pela spender
        bool success = myToken.transferFrom(owner, recipient, amount);

        assert(success);
        assertEq(myToken.balanceOf(owner), 5);
        assertEq(myToken.balanceOf(recipient), amount);
        assertEq(myToken.allowance(owner, spender), 0); 
    }

    function testTranferFromInvalid() public {
        address owner = address(this);
        address spender = address(0x01);
        address recipient = address(0x02);
        uint256 amount = myToken.balanceOf(owner) + 1; 

        myToken.approve(spender, amount);

        vm.prank(spender);
        vm.expectRevert("Insufficient balance");
        myToken.transferFrom(owner, recipient, amount);
    }

    // Testes de Fronteira

    function testTransferFromMaxAmount() public {
        address owner = address(this);
        address spender = address(0x01);
        address recipient = address(0x02);
        uint256 amount = type(uint256).max; 

        myToken.approve(spender, amount);

        vm.prank(spender);
        vm.expectRevert("Insufficient balance");
        myToken.transferFrom(owner, recipient, amount);
    }

    function testTransferToSelf() public {
        address recipient = address(this); 
        uint256 amount = 5;

        assert(myToken.transfer(recipient, amount));
        assertEq(myToken.balanceOf(address(this)), 10);
    }

    function testApprove_ZeroAmount() public {
        address spender = address(0x01);
        uint256 amount = 0;

        assert(myToken.approve(spender, amount));
        assertEq(myToken.allowance(address(this), spender), amount); // Permissão deve ser zero
    }

}   