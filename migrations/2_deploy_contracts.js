const Inventory = artifacts.require('./Inventory.sol')
const Market = artifacts.require('./Market.sol')

const EIP20 = artifacts.require('./Token/EIP20.sol')

const MarketLib = artifacts.require('./Libraries/MarketLib.sol')
const Random = artifacts.require('./Libraries/Random.sol')
const SafeMath = artifacts.require('./Libraries/SafeMath.sol')

module.exports = function(deployer) {
  deployer.deploy(EIP20)
  deployer.deploy(MarketLib)
  deployer.deploy(Random)
  deployer.deploy(SafeMath)
  deployer.deploy(Inventory)
  deployer.deploy(Market)
}
