// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Proxy {
    address public implementation;
    address public admin;          

    constructor(address _logic) payable {
        implementation = _logic;
        admin = msg.sender;
    }

    fallback() external {
        address _impl = implementation;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
    receive() external payable {}
    
}

contract Logic {
    address public isPremiumUser;
    address public securityAdmin;
    
    function upgradeToPremium(address _user) external {
        isPremiumUser = _user;
    }
    receive() external payable {}
    function withdraw() public {
        require(msg.sender == securityAdmin, "Not Admin");
        (bool ok,)=payable(msg.sender).call{value:address(this).balance}("");
        require(ok);
    }

}