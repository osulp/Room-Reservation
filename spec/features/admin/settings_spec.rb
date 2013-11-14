require 'spec_helper'

describe 'settings administration' do
  context 'when logged in as an admin' do
    let(:user) {build(:user, :admin)}
    before(:each) do
      RubyCAS::Filter.fake(user.onid)
      visit admin_settings_path
    end
    %w{max_concurrent_reservations}.each do |setting|
      describe setting do
        it_behaves_like 'a setting', setting
      end
    end
    %w{max_concurrent_reservations}.each do |setting|
      describe setting do
        it_behaves_like 'only accepting numerical value', setting
      end
    end
  end
end
