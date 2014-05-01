module DalliClientPatch
  extend ActiveSupport::Concern
  included do
    def get(key, options=nil)
     options ||= {}
     options[:deserialize] = true unless options.has_key?(:deserialize)
     perform(:get, key, options[:deserialize]) 
    end
  end
end
module DalliServerPatch
  extend ActiveSupport::Concern
  included do
    def get(key, deserialize=true)
      req = [::Dalli::Server::REQUEST, ::Dalli::Server::OPCODES[:get], key.bytesize, 0, 0, 0, key.bytesize, 0, 0, key].pack(::Dalli::Server::FORMAT[:get])
      write(req)
      generic_response(!!deserialize)
    end
  end
end
module DalliStorePatch
  extend ActiveSupport::Concern
  included do
    alias_method :orig_exist?, :exist?
    def exist?(name, options=nil)
      options ||= {}
      options[:deserialize] = true unless options.has_key?(:deserialize)
      orig_exist?(name, options)
    end
  end
end
::Dalli::Client.send(:include, DalliClientPatch)
::Dalli::Server.send(:include, DalliServerPatch)
::ActiveSupport::Cache.lookup_store(:dalli_store).class.send(:include, DalliStorePatch)
