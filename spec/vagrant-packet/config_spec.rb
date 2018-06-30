require "vagrant-packet/config"
require 'rspec/its'

# remove deprecation warnings
# (until someone decides to update the whole spec file to rspec 3.4)
RSpec.configure do |config|
  # ...
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

describe VagrantPlugins::Packet::Config do
  let(:instance) { described_class.new }

  # Ensure tests are not affected by Packet credential environment variables
  before :each do
    ENV.stub(:[] => nil)
  end

  describe "defaults" do

    subject do
      instance.tap do |o|
        o.finalize!
      end
    end

    its("packet_token")      { should be_nil }
    its("instance_ready_timeout") { should == 600 }
    its("project_id")        { should be_nil }
    its("hostname")          { should be_nil }
    its("plan")              { should be_nil }
    its("facility")          { should be_nil }
    its("operating_system")  { should == "ubuntu_16_04" }
    its("description")       { should be_nil }
    its("billing_cycle")     { should be_nil }
    its("always_pxe")        { should be_nil }
    its("ipxe_script_url")   { should be_nil }
    its("userdata")          { should be_nil }
    its("locked")            { should be_nil }
    its("hardware_reservation_id") { should be_nil }
    its("spot_instance")     { should be_nil }
    its("spot_price_max")    { should be_nil }
    its("termination_time")  { should be_nil }
    its("tags")              { should be_nil }
    its("project_ssh_keys")  { should be_nil }
    its("user_ssh_keys")     { should be_nil }
    its("features")          { should be_nil }
  end

  describe "overriding defaults" do
    # I typically don't meta-program in tests, but this is a very
    # simple boilerplate test, so I cut corners here. It just sets
    # each of these attributes to "foo" in isolation, and reads the value
    # and asserts the proper result comes back out.
    [:packet_token, :instance_ready_timeout, :project_id, :hostname, 
    :plan, :facility, :operating_system, :description, :billing_cycle,
    :always_pxe, :ipxe_script_url, :userdata, :locked, :hardware_reservation_id, 
    :spot_instance, :spot_price_max, :termination_time, :tags, :project_ssh_keys, 
    :user_ssh_keys, :features].each do |attribute|

      it "should not default #{attribute} if overridden" do
        # but these should always come together, so you need to set them all or nothing
        instance.send("packet_token=".to_sym, "foo")
        instance.send("#{attribute}=".to_sym, "foo")
        instance.send(attribute).should == "foo"
      end
    end
  end
end
