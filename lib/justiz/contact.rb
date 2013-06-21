require 'ostruct'

module Justiz
  class Contact < OpenStruct
    # std fields: court, location, post, phone, fax, justiz_id, url, email

    def id
      # too many duplicates
      #[court, justiz_id].compact.join("")
      # currently no duplicates
      [court, email].compact.join("")
    end

    def location_address
      Address.new(self[:location])
    end

    def post_address
      Address.new(self[:post])
    end
  end
end
