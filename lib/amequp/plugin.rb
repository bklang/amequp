require 'amqp'
require 'countdownlatch'

AMQP.logging = true

class Amequp::Plugin < Adhearsion::Plugin
  attr_reader :connection

  # Configure the connection information to your AMQP instance.
  config :amequp do
    uri         ''         , :desc => 'URI to the message queue. Use this OR specify each piece of connection information separately below.'
    username    ''         , :desc => 'valid message queue username'
    password    ''         , :desc => 'valid message queue password'
    hostname    'localhost', :desc => 'host where the message queue is running'
    port        5672       , :desc => 'port where the message queue is listening'
  end

  run :amequp, after: :punchblock do
    new.start Adhearsion.config[:amequp]
  end

  ##
  # Start the Redis connection with the configured database
  def start(config)
    params = config.to_hash.select { |k,v| !v.nil? }
    if params[:uri].nil? || params[:uri].empty?
      username, password = [params[:username], params[:password]].map { |i| CGI.escape i }
      params[:uri] = "amqp://#{username}:#{password}@#{params[:hostname]}:#{params[:port]}"
    else
      uri = URI.parse params[:uri]
      params[:username] = uri.user
      params[:password] = uri.password
      params[:hostname] = uri.hostname
      params[:port] = uri.port || params[:port]
    end

    establish_connection params
  end

  ##
  # Stop the AMQP connection
  def stop
    EM.next_tick { EM.stop }
  end

  ##
  # Start the connection to the configured Redis server
  #
  # @param params [Hash] Options to establish the Redis connection
  def establish_connection(params)
    latch = CountDownLatch.new 1

    Adhearsion::Events.shutdown do
      stop
    end

    Adhearsion::Events.amqp_connected do
      logger.info "Amequp connected to server at #{params[:hostname]}:#{params[:port]}"
      latch.countdown!
    end

    Adhearsion::Process.important_threads << Thread.new do
      catching_standard_errors { main_em_loop params }
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

  def main_em_loop(params)
    EM.run do
      ::AMQP.connect(params[:uri]) do |connection|
        Amequp.connection = @connection = connection
        Adhearsion::Events.trigger :amqp_connected
      end
    end
  end
end
