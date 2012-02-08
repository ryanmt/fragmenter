require 'spec_helper'

describe Fragmenter do 
  before :each do 
    @f = Fragmenter.new
  end
  it "generates an appropriate response" do
    resp = @f.fragment("REALPEPTIDE")
    resp.should be_a Array
    resp.size.should == 120
    resp.include?(157.101111).should be_true
  end
  it "handles a single charge state limitation" do 
    f = Fragmenter.new(:charge_states => false)
    resp = f.fragment("RYANASTAFK")
    resp.size.should == 54
    resp.include?(982.466821).should be_true
  end
  it "calculates more ions for the acceptable charge states" do 
    resp = @f.fragment("RYANASTAFK")
    resp.size.should == 162
    resp.include?(491.7334105).should be_true
  end
end
