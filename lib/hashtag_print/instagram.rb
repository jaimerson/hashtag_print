require 'hashtag_print/document'

module HashtagPrint
  class Instagram
    BASE_URL = 'http://picbear.com/tag/%s'
    attr_reader :browser

    def initialize
      @browser = open_browser
    end

    # @return [Hash]
    def search_by_hashtag(tag)
      retrying do
        browser.goto(url_for(tag))

        posts.map { |p| create_document(p) }
      end
    end

    def posts
      browser.divs(class: 'grid-media')
        .reject { |p| p.attribute_value('class').include?('grid-media-ad') }
    end

    def close
      browser.close
    end

    def reset
      browser.close
      @browser = open_browser
    end

    private

    def retrying
      result = yield
      @retries = 0
      result
    rescue Watir::Exception::Error, Net::ReadTimeout
      reset_browser && retry if (@retries += 1) < 5
    end

    def open_browser
      Watir::Browser.new
    end

    def create_document(post)
      footer = post.div(class: 'grid-media-footer')
      caption = footer.p(class: 'grid-media-caption')

      HashtagPrint::Document.new(
        user_name: footer.children.first.text.strip,
        image_url: post.img.src,
        caption: caption.exists? ? caption.text : ''
      )
    end

    def url_for(tag)
      format(BASE_URL, tag)
    end
  end
end
