require 'spec_helper'
require 'hesburgh/lib/html_scrubber'

RSpec.describe Hesburgh::Lib::HtmlScrubber do
  context '.build_inline_scrubber' do
    subject { described_class.build_inline_scrubber }
    it { should respond_to(:call) }
    {
      nil => '',
      %(<p>Hello</p>) => %(Hello),
      %(Hello) => %(Hello),
      %(<i>Hello<script><i>World</i></script></i>) => %(<i>Hello</i>),
      %(<script><i>Hello</i></script>) => %(),
      %(<p>Hello <a href="http://world.com" target="_blank">World</a></p>) => %(Hello <a href="http://world.com">World</a>),
      %(Hello <p>World <i>Are we there yet?</i></p>) => %(Hello World <i>Are we there yet?</i>)
    }.each do |input, expected|
      it "will scrub #{input.inspect} into #{expected.inspect}" do
        expect(subject.sanitize(input)).to eq(expected)
      end
    end

    context 'with tags: :fallback' do
      subject { described_class.build_inline_scrubber(tags: :fallback) }
      {
        nil => '',
        %(<p>Hello</p>) => %(<p>Hello</p>),
        %(Hello) => %(Hello),
        %(<i>Hello<script><i>World</i></script></i>) => %(<i>Hello</i>),
        %(<script><i>Hello</i></script>) => %(),
        %(<p>Hello <a href="http://world.com" target="_blank">World</a></p>) => %(<p>Hello <a href="http://world.com">World</a></p>),
        %(Hello <p>World <i>Are we there yet?</i></p>) => %(Hello <p>World <i>Are we there yet?</i></p>)
      }.each do |input, expected|
        it "will scrub #{input.inspect} into #{expected.inspect}" do
          expect(subject.sanitize(input)).to eq(expected)
        end
      end
    end

    context 'with attributes: :fallback' do
      subject { described_class.build_inline_scrubber(attributes: :fallback) }
      {
        nil => '',
        %(<p>Hello</p>) => %(Hello),
        %(Hello) => %(Hello),
        %(<script><i>Hello</i></script>) => %(),
        %(<i>Hello<script><i>World</i></script></i>) => %(<i>Hello</i>),
        %(<p>Hello <a href="http://world.com" bad_attr="_blank">World</a></p>) => %(Hello <a href="http://world.com">World</a>),
        %(Hello <p>World <i>Are we there yet?</i></p>) => %(Hello World <i>Are we there yet?</i>)
      }.each do |input, expected|
        it "will scrub #{input.inspect} into #{expected.inspect}" do
          expect(subject.sanitize(input)).to eq(expected)
        end
      end
    end
  end
  context '.build_block_scrubber' do
    subject { described_class.build_block_scrubber }
    it { should respond_to(:call) }
    {
      nil => '',
      %(<p>Hello</p>) => %(<p>Hello</p>),
      %(Hello) => %(Hello),
      %(<i>Hello<script><i>World</i></script></i>) => %(<i>Hello</i>),
      %(<script><i>Hello</i></script>) => %(),
      %(<p>Hello <a href="http://world.com" target="_blank">World</a></p>) => %(<p>Hello <a href="http://world.com">World</a></p>),
      %(Hello <p>World <i>Are we there yet?</i></p>) => %(Hello <p>World <i>Are we there yet?</i></p>)
    }.each do |input, expected|
      it "will scrub #{input.inspect} into #{expected.inspect}" do
        expect(subject.sanitize(input)).to eq(expected)
      end
    end
  end

  context '.build_meta_tag_scrubber' do
    subject { described_class.build_meta_tag_scrubber }
    it { should respond_to(:call) }
    {
      nil => '',
      %(<p>Hello</p>) => %(Hello),
      %(Hello) => %(Hello),
      %(<i>Hello<script><i>World</i></script></i>) => %(Hello),
      %(<script><i>Hello</i></script>) => %(),
      %(<p>Hello <a href="http://world.com" target="_blank">World</a></p>) => %(Hello World),
      %(Hello <p>World <i>Are we there yet?</i></p>) => %(Hello World Are we there yet?)
    }.each do |input, expected|
      it "will scrub #{input.inspect} into #{expected.inspect}" do
        expect(subject.sanitize(input)).to eq(expected)
      end
    end
  end
end
