require 'amqp'
require 'countdownlatch'

AMQP.logging = true

class Amequp::Plugin < Adhearsion::Plugin
  attr_reader :connection

  # Configure the connection information to your AMQP instance.
  config :amequp do
    uri         nil        , :desc => 'URI to the message queue. Use this OR specify each piece of connection information separately below.'
    username    ''         , :desc => 'valid message queue username'
    password    ''         , :desc => 'valid message queue password'
    hostname    'localhost', :desc => 'host where the message queue is running'
    port        5672       , :desc => 'port where the message queue is listening'
  end

  run :amequp, after: :punchblock do
    new.start
  end

  def start
    latch = CountDownLatch.new 1

    Adhearsion::Events.shutdown do
      stop
    end

    Adhearsion::Events.amqp_connected do
      logger.info "Amequp connected to server"
      latch.countdown!
    end

    Adhearsion::Process.important_threads << Thread.new do
      catching_standard_errors { main_em_loop }
    end

    latch.wait
  rescue => e
    # TODO: Graceful reconnections
    # We only care about disconnects if the process is up or booting
    return unless [:booting, :running].include? Adhearsion::Process.state_name

    logger.error e
    logger.fatal "AMQP connection failed. Going down."
    Adhearsion::Process.stop!
    raise e
  end

  private

  ##
  # Stop the AMQP connection
  def stop
    EM.next_tick { EM.stop }
  end

  def main_em_loop
    EM.run do
      Amequp.connection = @connection = ::AMQP.connect uri
      Adhearsion::Events.trigger :amqp_connected
    end
  end

  def uri
    config.uri || "amqp://#{config.username}:#{config.password}@#{config.hostname}:#{config.port}"
  end

  def config
    self.class.config
  end
end
