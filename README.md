## Thesis - Smart Contract Backend

This is one out of four repositories that cover the project created for my bachelors thesis. Briefly summarized, this project allows an Internet of Things (IoT) device to be managed indirectly via a smart contract on the Ethereum blockchain. IoT devices are able to function autonomously through a custom written middleware that interprets payloads received from the blockchain and converts them into actions. The usage of the system is streamlined through a react-based distributed frontend application.

**The projects repositories**:

| Name          | Repository    |
| ------------- |:-------------:|
| Smart Contract Backend      | [https://github.com/wickstjo/oracle-manager](https://github.com/wickstjo/oracle-manager) |
| Middleware Interpreter      | [https://github.com/wickstjo/oracle-manager](https://github.com/wickstjo/iot-manager) |
| Frontend Application        | [https://github.com/wickstjo/distributed-task-manager](https://github.com/wickstjo/distributed-task-manager)|
| Private Blockchain          | [https://github.com/wickstjo/thesis-chain](https://github.com/wickstjo/thesis-chain) |

## Content

This repository contains the smart contracts that form the projects backend system. The contracts are deployed to a private development blockchain that mimicks the actions of Ethereum's proof of work blockchain, so technically any other similarly working blockchain should work. To migrate the contracts to the blockchain, I used the [truffle framework](https://www.trufflesuite.com/).

**Points of Interest**:
- The truffle configuration can be located in the **truffle-config.js file**.
- To deploy and distribute the Binary Interface files to the other repos, modify the **scripts/migrate.py file**.

**In a Bash Terminal**:
- To normally compile and deploy the smart contracts, use **truffle migrate --network development**.
- To execute the customized deployment, use **./scripts/migrate.sh**.
