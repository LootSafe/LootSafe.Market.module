# LootSafe Market

The market module allows customers and merchants to exchange assets in a trustless mannor. Users deposit the items they wish to exchange into the market (via their own Inventory) then can either list offers or fulfill offers.

# Docs

## Methods

getTradesByMerchant

Returns the trades (both settled and active) for a given merchant.

```solidity
function getTradesByMerchant (address merchant) external constant returns (bytes32[] _trades)
```

## Test Coverage
```
 Contract: Market
    ✓ should deploy an Inventory (63ms)
    ✓ should deploy a Market (66ms)
    ✓ should create an inventory (368ms)
    ✓ should deposit to an inventory (451ms)
    ✓ should throw if merchant cannot fullfil trade (457ms)
    ✓ should create a trade on the market (480ms)
    ✓ should throw when withdrawaling assets locked in a trade on the market (487ms)
    ✓ should allow withdrawal with available assets with active trades (569ms)
    ✓ should settle a trade on the market (635ms)
    ✓ should allow withdrawal of items from settled offer (781ms)
    ✓ should list a merchants trades on the market (441ms)
    ✓ should list a all trades on the market (408ms)


  12 passing (5s)
  ```
  
  # WARNING THIS CONTRACT HAS NOT BEEN AUDITED YET, DO NOT USE IN PRODUCTION.
