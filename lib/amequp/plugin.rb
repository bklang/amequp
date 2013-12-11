require 'amqp'

class Amequp::Plugin < Adhearsion::Plugin
  extend ActiveSupport::Autoload

  autoload :Service, 'amequp/plugin/service'

  # Configure the connection information to your AMQP instance.
  config :amequp do
    uri         ''         , :desc => 'URI to the message queue. Use this OR specify each piece of connection information separately below.'
    username    ''         , :desc => 'valid message queue username'
    password    ''         , :desc => 'valid message queue password'
    hostname    'localhost', :desc => 'host where the message queue is running'
    port        5672       , :desc => 'port where the message queue is listening'
  end

  init :amequp do
    Service.start Adhearsion.config[:amequp]
  end
end
