// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {

    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        }else if(block.chainid == 1){
            activeNetworkConfig = getAnvilEthConfig();
        }
        else{
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory){

        NetworkConfig memory sepoliaConfig = NetworkConfig(
            {priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
            return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory){
        NetworkConfig memory mainnetConfig =  NetworkConfig(
            {priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
            return mainnetConfig;
    }

    function getAnvilEthConfig() public returns(NetworkConfig memory) {
        // if we have already deployed smartcontract, so to not deploy new one
        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }
        // 1.deploy the mocks   2.return the mock address
        // due to this we make contract helpConfig is Script

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8 , 2000e18);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }

}