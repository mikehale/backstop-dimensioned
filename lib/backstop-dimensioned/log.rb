module Backstop
  module Dimensioned
    module Log
      def log(data, &blk)
        Scrolls.log({:app => 'backstop-dimensioned', :ps => 'web'}.merge(data), &blk)
      end
    end
  end
end
