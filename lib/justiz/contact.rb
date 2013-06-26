require 'ostruct'
require 'digest'

module Justiz
  class Contact
    FIELDS = [:court, :location, :post, :phone, :fax, :justiz_id, :url, :email]
    attr_accessor :attributes, *FIELDS

    def initialize(attributes = {})
      self.attributes = attributes
    end

    def attributes=(attributes)
      attributes.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
    end

    def id
      # too many duplicates
      #[court, justiz_id].compact.join("")
      # currently no duplicates
      [court, email].compact.join("")
    end

    def location_address
      Address.new(location)
    end

    def post_address
      Address.new(post)
    end

    def digest
      sha256 = Digest::SHA2.new
      FIELDS.each do |field|
        sha256 << send(field)
      end
      Digest.hexencode(sha256.digest)
    end
  end
end
