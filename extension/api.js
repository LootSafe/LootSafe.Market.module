const getInstance = require('./tools/getInstance')
const marketAddress = '0xc0e755dd04e1a16db61b7545b645ec9a3ef7fdd2'

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
    },
    {
      endpoint: 'trades/:merchant',
      controller: (provider, ctx, merchant) => {
        return getInstance(provider, 'Market', marketAddress).then(async instance => {
          return instance.getTradesByMerchant.call(merchant)
        })
      }
    },
    {
      endpoint: 'trade/:tradeid',
      controller: (provider, ctx, tradeid) => {
        return getInstance(provider, 'Market', marketAddress).then(async instance => {
          return instance.getTrade.call(tradeid)
        })
      }
    }
  ]
}
