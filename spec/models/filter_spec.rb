require 'spec_helper'

describe Filter do

  it {should validate_presence_of(:name)}
  it {should have_many(:room_filters)}
  it {should have_many(:rooms).through(:room_filters)}
end
