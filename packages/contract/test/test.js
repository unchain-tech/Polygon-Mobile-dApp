const hre = require('hardhat');
const { expect } = require('chai');

describe('TodoContract', () => {
  // declare contract variable
  let contract;

  // deploy contract before all of the tests
  before(async () => {
    const contractFactory = await hre.ethers.getContractFactory('TodoContract');
    contract = await contractFactory.deploy();
  });

  // check creating function
  it('create function is working on chain', async () => {
    // check if you can create multiple tasks
    const receipt = await (await contract.createTask('make lunch')).wait();
    await contract.createTask('do the dises');
    await contract.createTask('have luch with friends');

    // check if you can read tasks
    expect((await contract.readTask(0))[1]).to.equal('make lunch');
    expect((await contract.readTask(1))[1]).to.equal('do the dises');
    expect((await contract.readTask(2))[1]).to.equal('have luch with friends');

    // check if event "TaskCreated" works
    expect(
      receipt.events?.filter((x) => {
        return x.event === 'TaskCreated';
      })[0].args[0],
    ).to.equal('make lunch');
  });

  it('update function is working on chain', async () => {
    // check if you can update tasks
    const receipt = await (await contract.updateTask(0, 'make dinner')).wait();
    await contract.updateTask(1, 'clean up the rooms');
    expect((await contract.readTask(0))[1]).to.equal('make dinner');
    expect((await contract.readTask(1))[1]).to.equal('clean up the rooms');

    // check if event "TaskUpdated" works
    expect(
      receipt.events?.filter((x) => {
        return x.event === 'TaskUpdated';
      })[0].args[0],
    ).to.equal('make dinner');
  });

  // check toggling function
  it('toggleComplete function is working on chain', async () => {
    // check if you can make a task completed
    const formerState = (await contract.readTask(0))[2];
    const receipt = await (await contract.toggleComplete(0)).wait();
    expect((await contract.readTask(0))[2]).to.equal(!formerState);

    // check if event "TaskIsCompleteToggled" works
    expect(
      receipt.events?.filter((x) => {
        return x.event === 'TaskIsCompleteToggled';
      })[0].args[0],
    ).to.equal('make dinner');
  });

  // check deleting function
  it('delete function is working on chain', async () => {
    // check if you can delete a task
    const receipt = await (await contract.deleteTask(0)).wait();
    expect((await contract.readTask(0))[1]).to.equal('');

    // check if event "TaskDeleted" works
    expect(
      receipt.events
        ?.filter((x) => {
          return x.event === 'TaskDeleted';
        })[0]
        .args[0].toNumber(),
    ).to.equal(0);
  });
});
