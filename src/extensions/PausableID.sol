// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Pauseable Token Id
 * @dev Allows accounts to be paused by a "pauser" role
 */
contract PauseableID {
    address private pauser;
    mapping(uint256 => bool) private paused;

    event PauseTokenId(uint256 indexed tokenId);
    event UnPauseTokenId(uint256 indexed tokenId);
    event PauserChanged(address indexed newPauser);

    /**
     * @dev reverts if called by any account other than the pauser
     */
    modifier onlyPauser() {
        require(msg.sender == pauser, "Only pauser");
        _;
    }

    /**
     * @dev Checks if token id is paused
     * @param _tokenId The token id to check
     */
    function isPaused(uint256 _tokenId) public view returns (bool) {
        return paused[_tokenId];
    }

    /**
     * @dev Adds token id to pause list
     * @param _tokenId The token id to pause list
     */
    function pauseTokenId(uint256 _tokenId) external onlyPauser {
        paused[_tokenId] = true;
        emit PauseTokenId(_tokenId);
    }

    /**
     * @dev Removes token id  from pause list
     * @param _tokenId The token id to remove from the pause list
     */
    function unPauseTokenId(uint256 _tokenId) external onlyPauser {
        paused[_tokenId] = false;
        emit UnPauseTokenId(_tokenId);
    }

    /**
     * @dev Changes the pauser role
     * @param _newPauser The address of the new pauser
     */
    function changePauser(address _newPauser) external {
        require(
            _newPauser != address(0),
            "Pauser can not be zero address"
        );
        pauser = _newPauser;
        emit PauserChanged(pauser);
    }
}