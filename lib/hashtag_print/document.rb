require 'digest/md5'

module HashtagPrint
  class Document
    HASHTAG_OR_MENTION_REGEX = /(#[a-zA-Z0-9_]+)|(@[a-zA-Z0-9_]+)/
    HASHTAG_REGEX = /(#[a-zA-Z0-9_]+)/
    MENTION_REGEX = /(@[a-zA-Z0-9_]+)/
    HANDLE_COLOR = '#F03030'.freeze

    attr_reader :user_name, :image_url, :caption

    def initialize(user_name:, image_url:, caption:)
      @user_name = user_name
      @image_url = image_url
      @caption = caption
    end

    def image
      decorated_image.crop_centered
    end

    def image_digest
      decorated_image.signature
    end

    def formatted_caption
      caption[0..250].split(HASHTAG_OR_MENTION_REGEX).map do |part|
        part = strong(part) if part =~ HASHTAG_REGEX
        part = color(strong(part)) if part =~ MENTION_REGEX
        part
      end.join
    end

    private

    def decorated_image
      HashtagPrint::Image.new(image_url)
    end

    def strong(string)
      "<strong>#{string}</strong>"
    end

    def color(string, rgb: HANDLE_COLOR)
      "<color rgb='#{rgb}'>#{string}</color>"
    end
  end
end
