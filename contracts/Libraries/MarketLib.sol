pragma solidity ^0.4.12;

library MarketLib {
    // Represents a trade offer
    struct Offer {
        address offer;
        address request;
        uint256 offerValue;
        uint256 requestValue;
        address merchant;
        address customer;
        uint settleTime;
        bool settled;
    }
}