module Justiz
  class Address
    attr_reader :text, :city, :plz, :street

    def initialize(text)
      @text = text.to_s
      parse
    end

    private

    def parse
      parts = text.split(/\s*,\s*/)
      if parts.length > 1
        @street = parts.slice(0, parts.length - 1).join(", ")
      end
      @plz, @city = parse_city(parts.last)
    end

    def parse_city(string)
      if string.to_s.match(/\s*([0-9]{5})\s*(.*)/i)
        [$1, $2]
      end
    end
  end
end