// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe,WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test{
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant FAKE_ETH = 10 ether;
    uint256 constant SEND_VALUE = 0.1 ether;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER , SEND_VALUE);
    }


    // this one was created by us:

    // function testUsercanFundInteractions() public {
    //     FundFundMe fundFundMe = new FundFundMe();
    //     // vm.prank(USER);
    //     // vm.deal(USER , FAKE_ETH);
    //     // fundFundMe.fundFundMe(address(fundMe));

    //     // address funder = fundMe.getFunders(0);
    //     // assertEq(funder , USER);
    //     fundFundMe.fundFundMe(address(fundMe)); 


    //     WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
    //     withdrawFundMe.withdrawFundMe(address(fundMe));

    //     assert(address(fundMe).balance == 0);
    // }





// by chatgpt

//     function testUsercanFundInteractions() public {
//     FundFundMe fundFundMe = new FundFundMe();

//     vm.deal(USER, FAKE_ETH);       // give USER 10 ETH
//     vm.prank(USER);                // make USER the caller
//     fundFundMe.fundFundMe(address(fundMe));

//     // check USER is stored as funder
//     address funder = fundMe.getFunders(0);
//     assertEq(funder, USER);

//     WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
//     vm.prank(fundMe.getOwner());   // withdrawals usually require owner
//     withdrawFundMe.withdrawFundMe(address(fundMe));

//     assertEq(address(fundMe).balance, 0);
// }



function testUsercanFundInteractions() public {
    vm.deal(USER, FAKE_ETH);       
    vm.prank(USER);                
    fundMe.fund{value: SEND_VALUE}();

    address funder = fundMe.getFunders(0);
    assertEq(funder, USER);

    vm.prank(fundMe.getOwner());   
    fundMe.withdraw();

    assertEq(address(fundMe).balance, 0);
}













}

