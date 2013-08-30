require 'spec_helper'

describe BannerRecord do
  subject{build(:banner_record)}
  describe "validations" do
    it {should validate_presence_of(:onid)}
  end

  describe ".osu_id=" do
    before do
      @prev_hash = subject.idHash
      subject.osu_id = "931590802"
    end

    it "should automatically populate idHash" do
      expect(subject.idHash).not_to be_empty
      expect(subject.idHash).not_to eq @prev_hash
      expect(subject.idHash.to_s).not_to eq "931590802"
    end
  end
  describe ".osu_id == " do
    before(:each) do
      subject.osu_id = "931590802"
    end
    it "should only match the correct number" do
      expect(subject.osu_id).not_to eq '931590801'
      expect(subject.osu_id).to eq '931590802'
    end
  end
  describe "#find_by_osu_id" do
    before(:each) do
      subject.osu_id = "931590802"
      subject.save
    end
    it "should return a matching record" do
      expect(BannerRecord.find_by_osu_id("931590802")).to eq subject
    end
    it "should raise ActiveRecord::RecordNotFound when not found" do
      expect{BannerRecord.find_by_osu_id("931590801")}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end