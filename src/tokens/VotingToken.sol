// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "openzeppelin-contracts/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import {ERC20Votes} from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract VotingToken is ERC20, ERC20Permit, ERC20Votes, Ownable {
    constructor(uint256 initialSupply)
    ERC20("VotingToken", "VTK")
    ERC20Permit("VotingToken") {
        _mint(msg.sender, initialSupply);
    }

    function mint(uint256 supply) onlyOwner external {
        _mint(msg.sender, supply);
    }

    // The functions below are overrides required by Solidity.
    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
}
