pragma solidity ^0.4.12;

import "./Market.sol";

contract MarketEvents {
    Market public market;

    modifier onlyMarket {
        require(msg.sender == address(market));
        _;
    }

    event InventoryCreated (address merchant, address inventory);

    event FundsWithdrawaled (address merchant, address asset, uint256 value);

    event TradeListed (
        address offer,
        address request, 
        uint256 offerValue,
        uint256 requestValue,
        address merchant
    );

    event TradeCancelled (bytes32 tradeId);
    event TradeFulfilled (bytes32 tradeId, address customer, uint at);

    function MarketEvents () public {
        market = Market(msg.sender);
    }

    function tradeListed(
        address offer,
        address request, 
        uint256 offerValue,
        uint256 requestValue,
        address merchant
    )
        public onlyMarket
    {
        TradeListed(
            offer,
            request,
            offerValue,
            requestValue,
            merchant
        );
    }

    function tradeCancelled(bytes32 tradeId) public onlyMarket {
        TradeCancelled(tradeId);
    }

    function tradeFulfilled(bytes32 tradeId, address customer, uint at) public onlyMarket {
        TradeFulfilled(tradeId, customer, at);
    }
    
    function inventoryCreated(address merchant, address inventory) public onlyMarket {
        InventoryCreated(merchant, inventory);
    }
    
    function fundsWithdrawaled(address merchant, address asset, uint256 value) public onlyMarket {
        FundsWithdrawaled(merchant, asset, value);
    }
}