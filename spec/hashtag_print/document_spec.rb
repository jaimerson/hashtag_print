require 'spec_helper'

RSpec.describe HashtagPrint::Document do
  let(:document) do
    described_class.new(
      user_name: user_name,
      image_url: image_url,
      caption: caption
    )
  end

  let(:user_name) { '@jaimersonn' }
  let(:image_url) { 'http://lorempixel.com/500/500/cats/' }

  describe '#formatted_caption' do
    subject(:formatted_caption) { document.formatted_caption }

    context 'when the caption does not need special foramtting' do
      let(:caption) { 'Lorem ipsum' }

      it 'returns the caption as it is' do
        expect(formatted_caption).to eq(caption)
      end
    end

    context 'when there are hashtags' do
      let(:caption) { 'Sou #foda #dig_din haha' }

      it 'returns a html formatted string' do
        expected_caption = 'Sou <strong>#foda</strong> <strong>#dig_din</strong> haha'
        expect(formatted_caption).to eq(expected_caption)
      end
    end

    context 'when there are @mentions' do
      let(:caption) { 'Hello @jaimersonn #nice' }
      let(:expected_caption) do
        color = described_class::HANDLE_COLOR
        "Hello <color rgb='#{color}'><strong>@jaimersonn</strong></color> <strong>#nice</strong>"
      end

      it 'formats the handle differently' do
        expect(formatted_caption).to eq(expected_caption)
      end
    end

    context 'when the caption is too long' do
      let(:caption) do
        <<~CAPTION
          Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam
          nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam
          erat, sed diam voluptua. At vero eos et accusam et justo duo dolores
          et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est
          Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur
          sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore
          et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam
          invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo
          duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
        CAPTION
      end

      it 'gets trimmed' do
        expect(formatted_caption.length).to eq(251)
      end
    end
  end
end
