require 'hashtag_print/instagram'

module HashtagPrint
  class Listener
    attr_reader :hashtag, :interval

    DEFAULT_INTERVAL = 3600 # seconds
    LIMIT_PER_USER   = 5  # pictures

    def initialize(hashtag, interval: DEFAULT_INTERVAL)
      @hashtag = hashtag
      @interval = interval
    end

    def listen
      puts "Listening to ##{hashtag}..."

      loop do
        client.search_by_hashtag(hashtag)
          .reject { |d| printed?(d) }
          .map { |d| save_to_pdf(d) }
          .reject { |d, _| printed?(d) || reached_limit_per_user?(d) }
          .map { |d, path| print(d, path) }
        puts "Waiting #{interval} seconds..."
        sleep interval
      end
    end

    private

    def reached_limit_per_user?(document)
      printed_per_user = YAML.load_file(printed_per_user_path) || {}
      reached_limit = printed_per_user[document.user_name].to_i >= LIMIT_PER_USER

      puts "#{document.user_name} already took too many pictures! Skipping..." if reached_limit

      reached_limit
    end

    def printed?(document)
      in_log = File.readlines(printed).map(&:strip).include?(document.image_digest)
      puts "Skipping already printed document" if in_log
      in_log
    end

    def downloaded?(document)
      in_log = File.readlines(downloaded).map(&:strip).include?(document.image_digest)
      puts "Skipping already downloaded document" if in_log
      in_log
    end

    def downloaded
      File.join(HashtagPrint::ROOT_PATH, 'etc', 'downloaded.txt')
    end

    def printed_per_user_path
      File.join(HashtagPrint::ROOT_PATH, 'etc', 'users.yml')
    end

    def printed
      File.join(HashtagPrint::ROOT_PATH, 'etc', 'printed.txt')
    end

    def save_to_pdf(document)
      rendered = HashtagPrint::Renderer.render(document)
      puts "Rendered #{rendered}"

      log_downloaded(document)
      log_user_picture(document)

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

    def log_user_picture(document)
      printed_per_user = YAML.load_file(printed_per_user_path) || {}
      pictures_count = printed_per_user[document.user_name].to_i
      printed_per_user[document.user_name] = printed_per_user[document.user_name].to_i + 1
      File.open(printed_per_user_path, 'w') { |f| YAML.dump(printed_per_user, f) }
    end

    def log_downloaded(document)
      File.open(downloaded, 'a+') do |file|
        file.puts(document.image_digest)
      end
    end

    def client
      @client ||= HashtagPrint::Instagram.new
    end
  end
end
