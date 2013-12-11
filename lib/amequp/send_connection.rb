module Amequp
  class << self
    def method_missing(m, *args, &blk)
      if Amequp::Plugin::Service.connection && Amequp::Plugin::Service.connection.respond_to?(m)
        Amequp::Plugin::Service.connection.send m, *args, &blk
      else
        super
      end
    end
  end
end
