var OracleManager = artifacts.require('OracleManager');
var TaskManager = artifacts.require('TaskManager');
var TokenManager = artifacts.require('TokenManager');
var UserManager = artifacts.require('UserManager');

module.exports = async function (deployer) {
    await deployer.deploy(OracleManager)
    await deployer.deploy(TaskManager)
    await deployer.deploy(TokenManager)
    await deployer.deploy(UserManager)
}