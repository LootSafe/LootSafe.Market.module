pragma solidity ^0.4.12;

library Random {
    function number (uint ceiling) constant internal returns (uint generatedNumber) {
        return (uint(block.blockhash(block.number - 1)) % ceiling + 1);
    }
}