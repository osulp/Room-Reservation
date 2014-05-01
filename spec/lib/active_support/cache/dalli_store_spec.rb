require 'spec_helper'
describe "Patched Dalli Functionality" do

  include MemcachedMock::Helper
  let(:key) {"bla"}
  context "when calling #exist" do
    context "and the key doesn't exist" do
      it "should return false" do
        memcached do
          connect
          expect(@dalli.exist? key).to eq false
        end
      end
    end
    context "and the key exists" do
      it "should return true" do
        memcached do
          connect
          @dalli.write(key, "Test")
          expect(@dalli.exist? key).to eq true
        end
      end
    end
    context "and an object is stored" do
      it "should be able to store objects" do
        client = nil
        memcached do
          connect
          client = @dalli
        end
        a = Reservation.new
        client.write(key, a)
        expect(client.read(key).class).to eq a.class
        expect(client.exist?(key)).to eq true
      end
    end
    it "should call Marshal.load by default" do
      client = nil
      memcached do
        connect
        client = @dalli
      end
      a = Reservation.new
      client.write(key, a)
      expect(Marshal).to receive(:load).and_call_original
      expect(client.exist?(key)).to eq true
    end
    it "should not call Marshal.load when passed :deserialize => false" do
      client = nil
      memcached do
        connect
        client = @dalli
      end
      a = Reservation.new
      client.write(key, a)
      expect(Marshal).not_to receive(:load)
      expect(client.exist?(key, :deserialize => false)).to eq true
    end
  end

  def connect
    @dalli = ActiveSupport::Cache.lookup_store(:dalli_store, 'localhost:19122', :expires_in => 10.seconds, :namespace => lambda{33.to_s(36)})
    @dalli.clear
  end
end
