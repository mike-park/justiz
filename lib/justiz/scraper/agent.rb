require 'mechanize'
require 'logger'

module Justiz
  module Scraper
    class Agent < Mechanize
      def initialize
        super do |config|
          config.default_encoding = 'UTF-8'
          config.force_default_encoding = true
        end
        self.log = Logger.new STDOUT
        self.user_agent_alias = 'Mac Safari'
      end
    end
  end
end
