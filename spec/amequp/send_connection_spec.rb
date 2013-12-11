require 'spec_helper'

describe Amequp do
  subject { Amequp::Plugin::Service }

  describe 'Amequp.do_something' do
    let(:connection) { double 'Amequp::Plugin::Service.connection' }

    it 'gets sent to Redis' do
      Amequp::Plugin::Service.stub(:connection).and_return connection
      connection.should_receive(:set).with "foo", "bar"

      Amequp.set "foo", "bar"
    end
  end
end
