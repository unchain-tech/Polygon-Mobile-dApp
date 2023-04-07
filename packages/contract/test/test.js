// eslint-disable-next-line no-undef
const TodoContract = artifacts.require(`TodoContract`);

require(`chai`).use(require('chai-as-promised')).should();
const { expect } = require('chai');

describe('Polygon-Mobile-dApp', () => {
  it('CRUD is working on chain', async () => {
    const contract = await TodoContract.new();

    // check if you can create a task
    await contract.createTask('make lunch');
    expect((await contract.readTask(0))[1]).to.equal('make lunch');

    // check if you can update task
    await contract.updateTask(0, 'make dinner');
    expect((await contract.readTask(0))[1]).to.equal('make dinner');

    // check if you can make a task completed
    const formerState = (await contract.readTask(0))[2];
    await contract.toggleComplete(0);
    expect((await contract.readTask(0))[2]).to.equal(!formerState);

    // check if you can delete a task
    await contract.deleteTask(0);
    expect((await contract.readTask(0))[1]).to.equal('');
  });
});
