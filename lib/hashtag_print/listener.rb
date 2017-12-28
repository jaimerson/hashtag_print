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
        puts "Searching for ##{hashtag}..."
        client.search_by_hashtag(hashtag)
          .reject { |d| printed?(d) }
          .map { |d| save_to_pdf(d) }
          .reject { |d, _| printed?(d) }
          .map { |d, path| print(d, path) }
        puts "Waiting #{interval} seconds..."
        sleep interval
      end
    end

    private

    def printed?(document)
      in_log = File.readlines(printed).map(&:strip).include?(document.image_digest)
      puts "Skipping already printed document" if in_log
    end

    def downloaded?(document)
      in_log = File.readlines(downloaded).map(&:strip).include?(document.image_digest)
      puts "Skipping already downloaded document" if in_log
    end

    def downloaded
      File.join(HashtagPrint::ROOT_PATH, 'etc', 'downloaded.txt')
    end

    def printed
      File.join(HashtagPrint::ROOT_PATH, 'etc', 'printed.txt')
    end

    def save_to_pdf(document)
      rendered = HashtagPrint::Renderer.render(document)
      puts "Rendered #{rendered}"

      File.open(downloaded, 'a+') do |file|
        file.puts(document.image_digest)
      end

      [document, rendered]
    end

    def print(document, path)
      enqueue = system('lpr', path)
      if enqueue
        puts "Enqueued #{path} to print"
        File.open(printed, 'a+') do |file|
          file.puts(document.image_digest)
        end
      end
    end

    def client
      @client ||= HashtagPrint::Instagram.new
    end
  end
end
