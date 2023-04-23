// eslint-disable-next-line no-undef
const TodoContract = artifacts.require(`TodoContract`);
const truffleAssert = require('truffle-assertions');

require(`chai`).use(require('chai-as-promised')).should();
const { expect } = require('chai');

// eslint-disable-next-line no-undef
contract('Polygon-Mobile-dApp', () => {
  // declare contract variable
  let contract;

  // deploy contract before all of the tests
  before(async () => {
    contract = await TodoContract.new();
  });

  // check create function
  it('create function is working on chain', async () => {
    // check if you can create multiple tasks
    const creationTX = await contract.createTask('make lunch');
    await contract.createTask('do the dises');
    await contract.createTask('have luch with friends');

    // check if you can read tasks
    expect((await contract.readTask(0))[1]).to.equal('make lunch');
    expect((await contract.readTask(1))[1]).to.equal('do the dises');
    expect((await contract.readTask(2))[1]).to.equal('have luch with friends');

    // check if event "TaskCreated" works
    truffleAssert.eventEmitted(creationTX, 'TaskCreated', (ev) => {
      return ev.taskNumber.toNumber() === 0 && ev.task === 'make lunch';
    });
  });

  // check update function
  it('update function is working on chain', async () => {
    // check if you can update tasks
    const updateTX = await contract.updateTask(0, 'make dinner');
    await contract.updateTask(1, 'clean up the rooms');
    expect((await contract.readTask(0))[1]).to.equal('make dinner');
    expect((await contract.readTask(1))[1]).to.equal('clean up the rooms');

    // check if event "TaskUpdated" works
    truffleAssert.eventEmitted(updateTX, 'TaskUpdated', (ev) => {
      return ev.taskId.toNumber() === 0 && ev.task === 'make dinner';
    });
  });
});
