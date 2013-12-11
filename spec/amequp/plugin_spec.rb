require 'spec_helper'

describe Amequp::Plugin do
  subject { Amequp::Plugin.new }

  describe '#start' do
    it 'should allow specifying a URI for the connection information' do
      config = {uri: 'amqp://amqpuser:amqppass@foo.bar.com:9530/'}
      expected_params = {
        username: 'amqpuser',
        password: 'amqppass',
        hostname: 'foo.bar.com',
        port: 9530,
        uri: 'amqp://amqpuser:amqppass@foo.bar.com:9530/'
      }
      subject.should_receive(:establish_connection).once.with(expected_params)
      subject.start config
    end

    it 'should default to the correct port if the URI does not specify one' do
      config = {uri: 'amqp://amqpuser:amqppass@foo.bar.com/', port: 6379}
      expected_params = {
        username: 'amqpuser',
        password: 'amqppass',
        hostname: 'foo.bar.com',
        port: 6379,
        uri: 'amqp://amqpuser:amqppass@foo.bar.com/'
      }
      subject.should_receive(:establish_connection).once.with(expected_params)
      subject.start config
    end
  end
end
