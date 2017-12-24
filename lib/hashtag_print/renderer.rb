require 'prawn'

# Renders a HashtagPrint::Document to a PDF with the given file name.
module HashtagPrint
  class Renderer
    def self.render(document)
      path = output_path(document.image_digest)

      Prawn::Document.generate(path) do
        font_families.update({
          'QuattrocentoSans' => {
            normal: 'fonts/QuattrocentoSans-Regular.ttf',
            bold: 'fonts/Quattrocento-Bold.ttf'
          }
        })

        bounding_box([0, cursor], width: 550, height: 730) do
          transparent(1, 0.3) do
            stroke_bounds
          end

          font_size 16

          image document.image, position: :center, fit: [550, 475]

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

      path
    end

    private

    def self.output_path(filename)
      File.join(HashtagPrint::ROOT_PATH, 'output', filename).to_s + '.pdf'
    end
  end
end
