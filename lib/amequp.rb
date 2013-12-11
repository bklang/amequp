module Amequp
  def work_queue(queue_name, &block)
    queue = channel.queue queue_name, auto_delete: true
    queue.subscribe &block
  end

  def work_topic(topic, routing_key, &block)
    channel.queue("", exclusive: true, auto_delete: true) do |queue|
      queue.bind(channel.topic(topic), routing_key: routing_key).subscribe &block
    end
  end

  def publish_message(payload)
    EM.next_tick { channel.topic('messages').publish payload }
  end
end

require "amequp/version"
require "amequp/plugin"
require "amequp/send_connection"
