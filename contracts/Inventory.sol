pragma solidity ^0.4.12;

import "./Token/EIP20Interface.sol";
import "./Market.sol";

// The Inventory holds all of the assets a merchant wishes to sell or trade
contract Inventory {
    Market public market; // Origin marketplace
    address public merchant; // Owner of this inventory

    modifier onlyMerchant {
        require(msg.sender == merchant);
        _;
    }

    modifier multiAuth {
        require(msg.sender == address(market) || msg.sender == merchant);
        _;
    }

    // Inventory constructor
    function Inventory (address _merchant) public {
        market = Market(msg.sender);
        merchant = _merchant;
    }
    
    // Allow the merchant to withdrawal assets from inventory
    // Also allows market to fulfill trades
    function withdrawal (address _asset, uint256 value) public multiAuth {
        EIP20Interface asset = EIP20Interface(_asset);
        asset.transfer(merchant, value);
    }
    
    function transfer (address _to, address _asset, uint256 _value) public multiAuth {
        EIP20Interface asset = EIP20Interface(_asset);
        asset.transfer(_to, _value);
    }

    // Retreive accidental ether sent to inventory
    function etherSaver () public onlyMerchant {
        msg.sender.transfer(this.balance);
    }
}
