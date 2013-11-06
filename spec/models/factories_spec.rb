require 'spec_helper'

describe 'validate FactoryGirl factories' do
  FactoryGirl.factories.each do |factory|
    next if factory.name == :user # Skip user for now - it's not an ActiveModel yet.
    context "with factory for :#{factory.name}" do
      subject { FactoryGirl.build(factory.name) }

      it 'is valid' do
        is_valid = subject.valid?
        expect(is_valid).to be_true, subject.errors.full_messages.join(',')
      end
    end
  end
end