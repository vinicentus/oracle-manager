const contracts = [
    'UserManager',
    'OracleManager',
    'TokenManager',
]

module.exports = (deployer) => {
    contracts.forEach(path => {
        deployer.deploy(
            artifacts.require('./contracts/' + path + '.sol')
        )
    })
}