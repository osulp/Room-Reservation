require 'spec_helper'

describe SwearFilter do
  subject {SwearFilter}
  describe ".profane?" do
    let(:result) {SwearFilter.profane?(word)}
    let(:word) {""}
    context "when passed an okay word" do
      let(:word) {"Hallo"}
      it "should return false" do
        expect(result).to be_false
      end
    end
    context "when passed a curse word" do
      let(:word) {"Shit"}
      it "should return true" do
        expect(result).to be_true
      end
    end
    context "when passed a curse word in a sentence" do
      let(:word) {"This is shit"}
      it "should return true" do
        expect(result).to be_true
      end
    end
    context "when passed a punctuated curse word" do
      let(:word) {"This is shit."}
      it "should return true" do
        expect(result).to be_true
      end
    end
    context "when passed nil" do
      let(:word) {nil}
      it "should return false" do
        expect(result).to be_false
      end
    end
    context "when passed a blank string" do
      let(:word) {""}
      it "should return false" do
        expect(result).to be_false
      end
    end
    context "when passed a multi-word curse word" do
      let(:word) {"finger bang"}
      it "should return true" do
        expect(result).to be_true
      end
    end
  end
end
