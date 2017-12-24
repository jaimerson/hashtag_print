require 'hashtag_print/instagram'

module HashtagPrint
  class Listener
    attr_reader :hashtag, :interval

    DEFAULT_INTERVAL = 30 # seconds

    def initialize(hashtag, interval: DEFAULT_INTERVAL)
      @hashtag = hashtag
      @interval = interval
    end

    def listen
      puts "Listening to #{hashtag}..."

      loop do
        client.search_by_hashtag(hashtag)
          .reject { |d| printed?(d) }
          .map { |d| save_to_pdf(d) }
        puts "Waiting #{interval} seconds..."
        sleep interval
      end
    end

    private

    def printed?(document)
      puts "Skipping already printed document"
      File.readlines(downloaded).map(&:strip).include?(document.image_digest)
    end

    def downloaded
      File.join(HashtagPrint::ROOT_PATH, 'etc', 'downloaded.txt')
    end

    def save_to_pdf(document)
      rendered = HashtagPrint::Renderer.render(document)
      puts "Rendered #{rendered}"

      File.open(downloaded, 'a+') do |file|
        file.puts(document.image_digest)
      end
    end

    def client
      @client ||= HashtagPrint::Instagram.new
    end
  end
end
