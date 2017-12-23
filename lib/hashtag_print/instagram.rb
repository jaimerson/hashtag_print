module HashtagPrint
  class Instagram
    BASE_URL = 'http://picbear.com/tag/%s'
    attr_reader :browser

    def initialize
      @browser = Watir::Browser.new
    end

    # @return [Hash]
    def search_by_hashtag(tag)
      browser.goto(url_for(tag))

      posts.map do |post|
        footer = post.div(class: 'grid-media-footer')
        caption = footer.p(class: 'grid-media-caption')

        {
          user_name: footer.children.first.text.strip,
          image_url: post.img.src,
          caption: caption.exists? ? caption.text : ''
        }
      end
    end

    def posts
      browser.divs(class: 'grid-media')
        .reject { |p| p.attribute_value('class').include?('grid-media-ad') }
    end

    def close
      browser.close
    end

    private

    def url_for(tag)
      format(BASE_URL, tag)
    end
  end
end
