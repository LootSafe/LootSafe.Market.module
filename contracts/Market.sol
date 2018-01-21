pragma solidity ^0.4.12;

import "./Inventory.sol";
import "./Libraries/Random.sol";
import "./Libraries/MarketLib.sol";
import "./Libraries/SafeMath.sol";
import "./Token/EIP20Interface.sol";

contract Market {
    using MarketLib for MarketLib.Offer;
    
    // ----------------------------------------------
    // ----------------- Events ---------------------
    // ----------------------------------------------

    event Trade (
        address offer,
        address request, 
        uint256 offerValue,
        uint256 requestValue,
        address merchant,
        address cutomer
    );

    event TradeListed (
        address offer,
        address request, 
        uint256 offerValue,
        uint256 requestValue,
        address merchant
    );


    // ----------------------------------------------
    // ---------------- Globals ---------------------
    // ----------------------------------------------

    address public owner;
 
    // Merchant => Inventory
    mapping (address => address) public inventories;

    // tradeid => Offer - lists all trades 
    mapping (bytes32 => MarketLib.Offer) public trades;

    // Merchant => (TradeID => Offer) - List all trades grouped by merchant
    mapping (address => bytes32[]) public tradesByMerchant;

    // All trade ids
    bytes32[] tradeIds;

    function Market() public {
        owner = msg.sender;
    }

    // ----------------------------------------------
    // ----------- Internal Functions ---------------
    // ----------------------------------------------

    event Test(bytes32 trade);
    // Check how many of an asset a merchant has locked in offers
    function _getOutstandingValue (address asset, address merchant) constant private returns (uint256 value) {
        bytes32[] memory merchantTrades = tradesByMerchant[merchant];
  
        uint outstandingValue;

        // If the merchant has made no trades this doesn't matter
        if (merchantTrades.length > 0) {
            for (uint i = 0; i < merchantTrades.length; i++) {
                MarketLib.Offer memory offer = trades[merchantTrades[i]];
                if (offer.offer == asset && !offer.settled) {
                    outstandingValue = SafeMath.add(outstandingValue, offer.offerValue);
                }
            }
        }

        return outstandingValue;
    }

    // Get the total balance of an asset a merchant has in their inventory
    function _getBalance(address asset, address merchant) constant private returns (uint256 _balance) {
        return EIP20Interface(asset).balanceOf(inventories[merchant]);
    }

    // ----------------------------------------------   
    // ------------ Getter Functions ----------------
    // ----------------------------------------------

    function getTradesByMerchant (address merchant) external constant returns (bytes32[] _trades) {
        return tradesByMerchant[merchant];
    }

    function getTrades () external constant returns (bytes32[] _trades) {
        return tradeIds;
    }

    function getTrade (bytes32 tradeId) external constant returns (
        address offer,
        address request,
        uint256 offerValue,
        uint256 requestValue,
        address merchant,
        address customer,
        bool settled
    ) {
        MarketLib.Offer memory _offer = trades[tradeId];
        return (
            _offer.offer,
            _offer.request,
            _offer.offerValue,
            _offer.requestValue,
            _offer.merchant,
            _offer.customer,
            _offer.settled
        );
    }

    function getMyInventory () external constant returns (address inventory) {
        return inventories[msg.sender];
    }
    
    // ----------------------------------------------   
    // ------------ Public Functions ----------------
    // ----------------------------------------------

    // Allow merchant to settle a trade enabling withdrawal of assets
    function settleTrade (bytes32 tradeId) external {
        MarketLib.Offer memory offer = trades[tradeId];

        // Only the merchant can settle a trade prematurely
        require(msg.sender == offer.merchant);

        offer.settled = true;
        trades[tradeId].settled = true;
    }

    // Allow safe withdrawal of un-utilized assets
    function withdrawal (address asset, uint256 value) public {
        // This is the total number of this asset locked up in trades
        uint256 outstandingValue = _getOutstandingValue(asset, msg.sender);
        uint balance = _getBalance(asset, msg.sender);

        // Ensure deducting this value would not cause offers to become unfillable
        require(SafeMath.sub(balance, outstandingValue) >= value);

        // Safely withdrawal assets
        Inventory(inventories[msg.sender]).withdrawal(asset, value);
    }
    
    // Create a new trade on the market
    function makeOffer(
        address _offer,
        address _request,
        uint256 _offerValue,
        uint256 _requestValue
    ) 
        external 
    {
        // Psuedo random trade identifier
        bytes32 tradeId = keccak256(Random.number(1333337));

        MarketLib.Offer memory offer = MarketLib.Offer({
            offer: _offer,
            request: _request,
            offerValue: _offerValue,
            requestValue: _requestValue,
            merchant: msg.sender,
            customer: 0x0,
            settled: false
        });

        TradeListed(
            offer.offer,
            offer.request,
            offer.offerValue,
            offer.requestValue,
            offer.merchant
        );

        // Require merchant to have enough of the item they 
        // wish to offer in their inventory
        uint256 balance = _getBalance(_offer, msg.sender);
        uint256 outstandingValue = _getOutstandingValue(_offer, msg.sender);

        require(SafeMath.sub(balance, outstandingValue) >= _offerValue);

        // Update trade references
        tradeIds.push(tradeId);
        trades[tradeId] = offer;
        tradesByMerchant[msg.sender].push(tradeId);
    }

    // Fulfill a trade on the market
    function fillOffer(bytes32 tradeId) external {
        MarketLib.Offer memory offer = trades[tradeId];
        
        // Ensure customer can fulfill trade
        uint256 customerBalance = _getBalance(msg.sender, offer.request);
        require(customerBalance >= offer.requestValue);

        // Ensure this trade is still active
        require(!offer.settled);

        Inventory merchantInventory = Inventory(inventories[offer.merchant]);
        Inventory customerInventory = Inventory(inventories[msg.sender]);

        // Send offer to customer
        merchantInventory.transfer(
            msg.sender,
            offer.offer,
            offer.offerValue
        );

        // Send request to merchant
        customerInventory.transfer(
            offer.merchant, 
            offer.offer, 
            offer.offerValue
        );

        // Update the trade to fulfilled status
        offer.customer = msg.sender;
        offer.settled = true;
        trades[tradeId] = offer;

        // Emit trade event
        Trade(
            offer.offer,
            offer.request,
            offer.offerValue,
            offer.requestValue,
            offer.merchant,
            msg.sender
        );
    }

    // Fallback is used to create a new inventory for merchant
    function () public payable {
        require(msg.value == 0);
        require(inventories[msg.sender] == 0x0);

        inventories[msg.sender] = address(
            new Inventory(msg.sender)
        );
    }
}