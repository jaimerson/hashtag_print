require 'mini_magick'

module HashtagPrint
  class Image
    attr_reader :image

    def initialize(image_url)
      @image = MiniMagick::Image.open(image_url)
    end

    def signature
      image.signature
    end

    def crop_centered
      size = [image[:width], image[:height]].min
      crop_instuctions = "#{size.to_i}x#{size.to_i}+0+0!"

      image.combine_options do |i|
        i.gravity :center
        i.crop crop_instuctions
      end

      file = StringIO.new
      image.write(file)
      file
    end

  end
end
