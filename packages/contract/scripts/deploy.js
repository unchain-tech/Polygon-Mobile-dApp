const hre = require('hardhat');
const main = async () => {
  const [deployer] = await hre.ethers.getSigners();
  const accountBalance = await deployer.getBalance();

  console.log('Deploying contracts with account: ', deployer.address);
  console.log('Account balance: ', accountBalance.toString());

  const todoContractFactory = await hre.ethers.getContractFactory(
    'TodoContract',
  );
  /* コントラクトに資金を提供できるようにする */
  const todoContract = await todoContractFactory.deploy();

  await todoContract.deployed();

  console.log('TodoContract address: ', todoContract.address);
};

const runMain = async () => {
  try {
    await main();
  } catch (error) {
    console.error(error);
    throw new Error('there is error!');
  }
};

runMain();
