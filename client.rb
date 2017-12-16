$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require 'rubygems'
require 'bundler/setup'

Bundler.setup(:default)

require 'watir'
require 'pry'
require 'prawn'
require 'open-uri'

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

  class Document
    HASHTAG_OR_MENTION_REGEX = /(#[a-zA-Z0-9]+\b)|(@[a-zA-Z0-9]+\b)/
    HASHTAG_REGEX = /(#[a-zA-Z0-9]+\b)/
    MENTION_REGEX = /(@[a-zA-Z0-9]+\b)/

    attr_reader :user_name, :image_url, :caption

    def initialize(user_name, image_url, caption)
      @user_name = user_name
      @image_url = image_url
      @caption = caption
    end

    def formatted_caption
      caption[0..300].split(HASHTAG_OR_MENTION_REGEX).map do |part|
        part = "<strong>#{part}</strong>" if part =~ HASHTAG_REGEX
        part = "<color rgb='#F03030'>#{part}</color>" if part =~ MENTION_REGEX
        part
      end.join
    end
  end
end

client = HashtagPrint::Instagram.new
posts = client.search_by_hashtag('casamentorosaejames').map do |post|
  HashtagPrint::Document.new(*post.values_at(:user_name, :image_url, :caption))
end

Prawn::Document.generate('output/test.pdf') do
  font_families.update({
    'QuattrocentoSans' => {
      normal: 'fonts/QuattrocentoSans-Regular.ttf',
      bold: 'fonts/Quattrocento-Bold.ttf'
    }
  })

  bounding_box([20, cursor], width: 500, height: 600) do
    transparent(1, 0.3) do
      stroke_bounds
    end

    font_size 16

    move_down 20

    image open(posts.last.image_url), position: :center, fit: [450, 450]

    indent(20) do
      move_down 20

      font('QuattrocentoSans', style: :bold) do
        text posts.last.user_name, color: 'F03030'
      end

      move_down 20

      font 'QuattrocentoSans'
      text posts.last.formatted_caption, inline_format: true
    end
  end
end

binding.pry

at_exit do
  binding.pry
  client.close
end
