require 'prawn'
require 'open-uri'

# Renders a HashtagPrint::Document to a PDF with the given file name.
module HashtagPrint
  class Renderer
    attr_reader :document, :output_path

    # @param document [HashtagPrint::Document] the document to render
    # @param file_name [String] name of file to be saved
    def initialize(document, file_name)
      @document = document
      @output_path = HashtagPrint::ROOT_PATH.join('output', file_name, '.pdf')
    end

    def render
      Prawn::Document.generate(output_path) do
        setup_font
        inside_box do
          font_size 16
          move_down 20

          image open(document.image_url), position: :center, fit: [450, 450]

          indent(20) do
            move_down 20

            font('QuattrocentoSans', style: :bold) do
              text document.user_name, color: 'F03030'
            end

            move_down 20

            font 'QuattrocentoSans'
            text document.formatted_caption, inline_format: true
          end
        end
      end
    end

    private

    def setup_font
      font_families.update({
        'QuattrocentoSans' => {
          normal: 'fonts/QuattrocentoSans-Regular.ttf',
          bold: 'fonts/Quattrocento-Bold.ttf'
        }
      })
    end

    def inside_box
      bounding_box([20, cursor], width: 500, height: 600) do
        transparent(1, 0.3) do
          stroke_bounds
        end
        yield
      end
    end
  end
end
