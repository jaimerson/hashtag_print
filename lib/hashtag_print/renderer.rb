require 'prawn'
require 'prawn/measurement_extensions'

# Renders a HashtagPrint::Document to a PDF with the given file name.
module HashtagPrint
  class Renderer
    def self.render(document)
      path = output_path(document.image_digest)

      Prawn::Document.generate(path, margin: [2.5.mm,2.5.mm,2.5.mm,2.5.mm], page_size: [10.cm, 15.cm]) do
        font_families.update({
          'QuattrocentoSans' => {
            normal: 'fonts/QuattrocentoSans-Regular.ttf',
            bold: 'fonts/Quattrocento-Bold.ttf'
          }
        })

        bounding_box([0, cursor], width: 95.mm, height: 145.mm) do
          transparent(1, 0.3) do
            stroke_bounds
          end

          font_size 12

          image document.image, position: :center, fit: [95.mm, 95.mm]

          indent(2.mm) do
            move_down 2.mm

            font('QuattrocentoSans', style: :bold) do
              text document.user_name, color: 'F03030'
            end

            move_down 2.mm

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
