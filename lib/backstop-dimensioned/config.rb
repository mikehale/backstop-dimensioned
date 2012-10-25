module Backstop
  module Config
    def self.env(key)
      ENV[key]
    end
    
    def self.env!(key)
      env(key) || raise("missing #{key}")
    end
    
    def self.librato_uri
      URI.parse(env!("LIBRATO_URI"))
    end
  end
end
