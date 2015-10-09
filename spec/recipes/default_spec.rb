RSpec.describe 'testsetup::default' do
  include ChefRun

  it 'successfully backed up the printer queues' do
    expect(chef_run).to include_recipe(described_recipe)
  end
end
