module HashtagPrint
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
