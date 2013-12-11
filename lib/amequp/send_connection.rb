module Amequp
  class << self
    def method_missing(m, *args, &blk)
      if Amequp::Plugin.connection && Amequp::Plugin.connection.respond_to?(m)
        Amequp::Plugin.connection.send m, *args, &blk
      else
        super
      end
    end
  end
end
