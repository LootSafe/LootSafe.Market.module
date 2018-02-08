const Web3 = require('web3')
const contract = require('truffle-contract')

const statefulCall = function (provider, contractName, address = false) {
  const prov = new Web3.providers.HttpProvider(provider)
  const web3 = new Web3(prov)
  const artifacts = require(`../../build/contracts/${contractName}.json`)
  const abi = contract(artifacts)

  abi.setProvider(web3.currentProvider)
  return abi.at(address).then(instance => {
    return instance
  })
}

module.exports = statefulCall
