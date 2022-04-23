//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LiqualityToken is ERC20, Ownable {
    constructor() ERC20("LiqualityToken", "LQTX") {}

    event MintLQTXFinished(address account, uint256 amount);
    event BurnLQTXFinished(address account, uint256 amount);

    function mint(address _account, uint256 _amount) public onlyOwner {
        _mint(_account, _amount);

        emit MintLQTXFinished(_account, _amount);
    }

    function burn(address _account, uint256 _amount) public onlyOwner {
        _burn(_account, _amount);

        emit BurnLQTXFinished(_account, _amount);
    }
}
