// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library HelperLib {
	    function getPercentage(uint256 amount, uint256 percent)
        public
        pure
        returns (uint256 percentOfAmount)
    {
        return (amount * percent) / 100;
    }
}