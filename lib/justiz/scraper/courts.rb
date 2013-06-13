module Justiz
  module Scraper
    class Courts

      def scrape(court_type, state)
        form = home_page.forms[2]
        form['gerausw'] = court_type
        form['landausw'] = state
        page = agent.submit(form, form.buttons_with(name: 'suchen1').first)
        parse_page(page)
      end

      private

      def home_page
        @home_page ||= agent.get('http://www.justizadressen.nrw.de/og.php?MD=nrw')
      end

      def agent
        @agent ||= Justiz::Scraper::Agent.new
      end

      def parse_page(page)
        find_limit_warning(page)

        rows = page.search('tr').map { |tr| tr.search('td').to_a }
        contact_rows = rows.find_all { |row| row.length == 3 }
        contact_rows.map do |court, addresses, phones|
          addresses = AddressTd.new(addresses)
          phones = AddressTd.new(phones)

          Justiz::Contact.new.merge court: court.text.strip,
                                    location: addresses.lieferanschrift,
                                    post: addresses.postfach,
                                    phone: phones.telefone,
                                    fax: phones.fax,
                                    justiz_id: phones.justiz_id,
                                    url: phones.url,
                                    email: phones.email
        end
      end

      def find_limit_warning(page)
        if page.search('p').find {|p| p.text =~ /Ihre Suchanfrage ergab mehr als/i}
          puts ">>> Not all contacts listed <<<"
        end
      end

      class AddressTd
        attr_reader :texts

        def initialize(node)
          nodes = node.children.to_a
          @texts = nodes.map { |n| n.text.strip }.find_all { |t| !blank?(t) }
        end

        def telefone
          same_line('Telefon:')
        end

        def fax
          same_line('Fax:')
        end

        def justiz_id
          same_line('XJustiz-ID:')
        end

        def lieferanschrift
          next_line('Lieferanschrift')
        end

        def postfach
          next_line('Postanschrift')
        end

        def url
          next_line('URL')
        end

        def email
          next_line('Mail')
        end

        private

        def blank?(something)
          something.to_s !~ /[^[:space:]]/
        end

        def next_line(name)
          reg = Regexp.new(name, true)
          line = texts.find_index { |text| text.match(reg) }
          line && texts[line + 1]
        end

        def same_line(name)
          reg = Regexp.new("#{name}(.*)", true)
          text = texts.map { |t| t.match(reg) }.compact.first
          text = text[1].strip if text
          text if !blank?(text)
        end
      end
    end
  end
end
