// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface IrwAsset {
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function hasRole(bytes32 role, address account) external view returns (bool);
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
    function ADMIN_ROLE() external view returns (bytes32);
    function MINTER_ROLE() external view returns (bytes32);
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function mint(address account, uint256 amount) external;
    function burn(address account, uint256 amount) external;
}