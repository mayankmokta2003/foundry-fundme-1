// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundMe;
    address USER = makeAddr("user");  // makes a dummy user
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant FAKE_ETH = 10 ether;

    function setUp() external {
        //  fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER , FAKE_ETH);
    }
    function testdollar()view  public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function findSender()view  public {
        assertEq(fundMe.i_owner() , msg.sender);
    }

    function checkGetversion() view public {
        uint256 version = fundMe.getVersion();
        assertEq(version , 4);
        // assertEq(fundMe.getVersion(),4);
    }

    function testFundFailsWithoutEnoughEth() public {
        // this vm says that hey the next line should revert means this tx fails.
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        // vm.deal(USER , FAKE_ETH);
        vm.prank(USER); // the next tx will be sent by user
        fundMe.fund{value: SEND_VALUE}();
        
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded , SEND_VALUE);
    }

    modifier funded{
        // vm.deal(USER , FAKE_ETH);
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testAddsFunderToArrayOfFunders() public funded{
        // vm.deal(USER, FAKE_ETH);
        // vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunders(0);
        assertEq(funder , USER);
    }

    function testOnlyOwnerCanWithdraw() public funded{
        // vm.deal(USER, FAKE_ETH);
        // vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();

    }

    function testWithdrawWithASingleOwner() public funded{
        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance , 0);
        assertEq(startingFundMeBalance + startingOwnerBalance , endingOwnerBalance);
    }

    function testWithdrawFromMultipleUsers() public funded{
        // arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            // when we create more than 1 address then we use uint160
            hoax(address(i) , SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act 
        // vm.prank(fundMe.getOwner());
        // fundMe.withdraw();   or we can use
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }


    function testWithdrawFromMultipleUsersCheaper() public funded{
        // arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            // when we create more than 1 address then we use uint160
            hoax(address(i) , SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act 
        // vm.prank(fundMe.getOwner());
        // fundMe.withdraw();   or we can use
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }


}

