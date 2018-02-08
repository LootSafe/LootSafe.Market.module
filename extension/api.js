const getInstance = require('./tools/getInstance')
const marketAddress = '0x0000000000000000000000000000000000000000'

module.exports = {
    // Deployed address of module
    contract: marketAddress,
    endpoint: 'market',
    routes: [ // Read only routes for module
        {
            endpoint: 'trades',
            controller: (provider) => {
                return getInstance(provider, 'Market', marketAddress).then(async instance => {
                    return instance.getTrades.call()
                })
            }
        }
    ]
}