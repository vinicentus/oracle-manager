var OracleManager = artifacts.require('OracleManager');
var TaskManager = artifacts.require('TaskManager');
var TokenManager = artifacts.require('TokenManager');
var UserManager = artifacts.require('UserManager');

// All of these varabels can be customized to your liking
tokenSymbol = 'ArcaCoin'
tokenPrice = 5000
tokenCapacity = 10000

taskTokenFee = 2

// Call the init function on every contract,
// linking them together by giving them references to each other
// and giving them other initial parameters
module.exports = async function (deployer) {
    tokenManagerDeployed = await TokenManager.deployed()
    taskManagerDeployed = await TaskManager.deployed()
    userManagerDeployed = await UserManager.deployed()
    oracleManagerDeployed = await OracleManager.deployed()

    await tokenManagerDeployed.init.sendTransaction(
        tokenSymbol,
        tokenPrice,
        tokenCapacity,
        taskManagerDeployed.address,
    )

    await taskManagerDeployed.init.sendTransaction(
        taskTokenFee,
        userManagerDeployed.address,
        oracleManagerDeployed.address,
        tokenManagerDeployed.address
    )

    await userManagerDeployed.init.sendTransaction(
        taskManagerDeployed.address
    )

    await oracleManagerDeployed.init.sendTransaction(
        userManagerDeployed.address,
        taskManagerDeployed.address
    )
}