// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "forge-std/console.sol";

contract BaseToken is ERC20, AccessControl {
    // Define the roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Define the events
    event AdminRoleGranted(address indexed account);
    event MinterRoleGranted(address indexed account);

    // Define the constructor
    // @dev - grant the DEFAULT_ADMIN_ROLE, ADMIN_ROLE, and MINTER_ROLE to the deployer
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        grantRole(ADMIN_ROLE, _msgSender());
        grantRole(MINTER_ROLE, _msgSender());
    }

    // Define the modifiers
    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, _msgSender()), "BaseToken: must have admin role to perform this action");
        _;
    }

    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, _msgSender()), "BaseToken: must have minter role to perform this action");
        _;
    }

    // Define the functions
    // @dev - define mint and burn functions as onlyMinter
    function mint(address account, uint256 amount) public onlyMinter {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyMinter {
        _burn(account, amount);
    }

// @dev - what functions are are admin specific other than grant and revoke role?

}

