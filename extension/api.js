module.exports = {
    // Deployed address of module
    contract: '0x0000000000000000000000000000000000000000',
    endpoint: 'market',
    routes: [ // Read only routes for module
        {
            endpoint: 'trades',
            controller: (ctx) => {
                ctx.body = {
                    "test": 123
                }
            }
        }
    ]
}