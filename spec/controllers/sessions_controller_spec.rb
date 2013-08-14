require 'spec_helper'

describe SessionsController do
  describe '.new' do
    context "when not logged in" do
      before(:each) do
        get :new
      end
      it "should redirect to CAS" do
        expect(response).to be_redirect
        expect(response).not_to redirect_to root_path
      end
    end
    context "when logged in" do
      before(:each) do
        RubyCAS::Filter.fake("test")
        get :new
      end
      it "should redirect back to the root path" do
        expect(response).to redirect_to root_path
      end
    end
  end
end
