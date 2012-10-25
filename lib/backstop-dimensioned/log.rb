module Backstop
  module Dimensioned
    module Log
      def log(data, &blk)
        Scrolls.log(data.merge(:app => 'backstop-dimensioned', :ps => 'web'), &blk)
      end
    end
  end
end
