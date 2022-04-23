//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract Liquality is Ownable, ReentrancyGuard, Pausable {
    uint256 splitAmountETH;
    uint256 streamingTimeETH;
    uint256 startTimeETH;
    uint256 totalwithdrawnETH;
    bool startedSplitETH;

    address splitAddrToken;
    uint256 splitAmountToken;
    uint256 streamingTimeToken;
    uint256 startTimeToken;
    uint256 totalwithdrawnToken;
    bool startedSplitToken;

    // Mapping for account => share permille
    mapping(address => uint16) private _shareETHOfAccount; // Permille
    mapping(address => uint256) private _splitETHOfAccount; // ETH
    mapping(address => uint256) private _withdrawnETHOfAccount; // ETH

    // Mapping for account => share permille
    mapping(address => uint16) private _shareTokenOfAccount; // Permille
    mapping(address => uint256) private _splitTokenOfAccount; // ETH
    mapping(address => uint256) private _withdrawnTokenOfAccount; // ETH

    /*///////////////////////////////////////////////////////////////
                            OVERRIDE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Public function(only Owner) to set the modifier to pause
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Public function(only Owner) to set the modifier to unpause
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /*///////////////////////////////////////////////////////////////
                            SPLIT LOGIC 
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Start the split ETH.
     */
    function startSplitETH(
        uint256 _splitAmountETH,
        address[] memory _accounts,
        uint16[] memory _shares,
        uint256 _streamingTimeETH
    ) public onlyOwner {
        require(!startedSplitETH, "The split has already started!");
        require(_splitAmountETH > 0, "Zero split ETH");
        splitAmountETH = _splitAmountETH;
        streamingTimeETH = _streamingTimeETH;
        for (uint256 i = 0; i < _accounts.length; i++) {
            _shareETHOfAccount[_accounts[i]] = _shares[i];
            _splitETHOfAccount[_accounts[i]] =
                (splitAmountETH * _shareETHOfAccount[_accounts[i]]) /
                1000;
        }
        startTimeETH = block.timestamp;
        startedSplitETH = true;
    }

    /**
     * @dev Claim the split ETH by account.
     */
    function claimETH() external payable nonReentrant {
        require(startedSplitETH, "The split has not started!");
        require(_splitETHOfAccount[msg.sender] > 0, "No split quota!");
        uint256 calculatedAmount = _splitETHOfAccount[msg.sender];
        if (block.timestamp < startTimeETH + streamingTimeETH) {
            calculatedAmount =
                (_splitETHOfAccount[msg.sender] *
                    (block.timestamp - startTimeETH)) /
                streamingTimeETH;
        }
        uint256 claimAmount = calculatedAmount -
            _withdrawnETHOfAccount[msg.sender];
        require(claimAmount > 0, "Already withdrawn all!");
        if (totalwithdrawnETH + claimAmount <= splitAmountETH) {
            // payable(msg.sender).transfer(claimAmount);
            (bool success, ) = payable(msg.sender).call{value: claimAmount}("");

            _withdrawnETHOfAccount[msg.sender] += claimAmount;
            totalwithdrawnETH += claimAmount;
            if (totalwithdrawnETH == splitAmountETH) {
                startedSplitETH = false;
            }
        }
    }

    /**
     * @dev Start the split Token.
     */
    function startSplitToken(
        address _splitAddrToken,
        uint256 _splitAmountToken,
        address[] memory _accounts,
        uint16[] memory _shares,
        uint256 _streamingTimeToken
    ) public onlyOwner {
        require(!startedSplitToken, "The split has already started!");
        require(_splitAmountToken > 0, "Zero split Token");
        splitAddrToken = _splitAddrToken;
        splitAmountToken = _splitAmountToken;
        streamingTimeToken = _streamingTimeToken;
        for (uint256 i = 0; i < _accounts.length; i++) {
            _shareTokenOfAccount[_accounts[i]] = _shares[i];
            _splitTokenOfAccount[_accounts[i]] =
                (splitAmountToken * _shareTokenOfAccount[_accounts[i]]) /
                1000;
        }
        startTimeToken = block.timestamp;
        startedSplitToken = true;
    }

    /**
     * @dev Claim the split Token by account.
     */
    function claimToken() public nonReentrant {
        require(startedSplitToken, "The split has not started!");
        require(_splitTokenOfAccount[msg.sender] > 0, "No split quota!");
        uint256 calculatedAmount = _splitTokenOfAccount[msg.sender];
        if (block.timestamp < startTimeToken + streamingTimeToken) {
            calculatedAmount =
                (_splitTokenOfAccount[msg.sender] *
                    (block.timestamp - startTimeToken)) /
                streamingTimeToken;
        }
        uint256 claimAmount = calculatedAmount -
            _withdrawnTokenOfAccount[msg.sender];
        require(claimAmount > 0, "Already withdrawn all!");
        if (totalwithdrawnToken + claimAmount <= splitAmountToken) {
            IERC20(splitAddrToken).transfer(msg.sender, claimAmount);
            _withdrawnTokenOfAccount[msg.sender] += claimAmount;
            totalwithdrawnToken += claimAmount;
            if (totalwithdrawnToken == splitAmountToken) {
                startedSplitToken = false;
            }
        }
    }

    /*///////////////////////////////////////////////////////////////
                            UTILS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Check if address is contract.
     */
    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    /**
     * @dev Get the split token contract address.
     */
    function getSplitTokenContract() public view returns (address) {
        return splitAddrToken;
    }

    /**
     * @dev Get the split ETH amount.
     */
    function getsplitAmountETH() public view returns (uint256) {
        return splitAmountETH;
    }

    /**
     * @dev Get the split Token amount.
     */
    function getsplitAmountToken() public view returns (uint256) {
        return splitAmountToken;
    }

    /**
     * @dev Get the split ETH amount of Account.
     */

    function getSplitETHOfAccount() public view returns (uint256) {
        return _splitETHOfAccount[msg.sender];
    }

    /**
     * @dev Get the withdrawn ETH amount of Account.
     */
    function getWithdrawnETHOfAccount() public view returns (uint256) {
        return _withdrawnETHOfAccount[msg.sender];
    }

    /**
     * @dev Get the split Token amount of Account.
     */
    function getSplitTokenOfAccount() public view returns (uint256) {
        return _splitTokenOfAccount[msg.sender];
    }

    /**
     * @dev Get the withdrawn Token amount of Account.
     */
    function getWithdrawnTokenOfAccount() public view returns (uint256) {
        return _withdrawnTokenOfAccount[msg.sender];
    }

    /**
     * @dev Get the contract balance.
     */
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /*///////////////////////////////////////////////////////////////
                            TEST FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function setStartTimeETH(uint256 _startTimeETH) public {
        startTimeETH = _startTimeETH;
    }

    function setStartTimeToken(uint256 _startTimeToken) public {
        startTimeToken = _startTimeToken;
    }

    function getSplitETHStatus() public view returns (bool) {
        return startedSplitETH;
    }

    function getSplitTokenStatus() public view returns (bool) {
        return startedSplitToken;
    }
}
