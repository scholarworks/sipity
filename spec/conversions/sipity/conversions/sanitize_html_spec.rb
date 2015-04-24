require 'spec_helper'

module Sipity
  module Conversions
    describe SanitizeHtml do
      include ::Sipity::Conversions::SanitizeHtml

      context '.call' do
        it 'will call the underlying conversion method' do
          expect(described_class.call('<p><script>alert("test");</script></p>')).to eq('<p>alert("test");</p>')
        end
      end

      context '.sanitize_html' do
        it 'will be private' do
          expect { described_class.sanitize_html(true) }.
            to raise_error(NoMethodError, /private method `sanitize_html'/)
        end
      end

      context '#call' do
        it 'will not be implemented' do
          expect(self).to_not respond_to(:call)
        end
      end

      context '#sanitize_html' do

        it 'will be a private instance method' do
          expect(self.class.private_instance_methods).to include(:sanitize_html)
        end

        context 'Sanitizing HTML output' do
          it 'will sanitize nil as an empty string' do
            expect(sanitize_html(nil)).to eq('')
          end
          it 'removes script tags' do
            text = <<-eos.gsub(/^ {14}/, '')
              A malicious user could try to inject JavaScript directly into the
              HTML via a script tag. <script>alert('Like this');</script>
            eos
            expect(sanitize_html(text)).to_not have_tag('script')
          end

          it 'removes JavaScript links' do
            text = <<-eos.gsub(/^ {14}/, '')
              JavaScript can also be included in an anchor tag
              <a href="javascript:alert('CLICK HIJACK');">like so</a>
            eos
            expect(sanitize_html(text)).to_not have_tag("a[href]")
          end

          it 'should be html_safe' do
            text = <<-eos.gsub(/^ {14}/, '')
              JavaScript can also be included in an anchor tag
              <a href="javascript:alert('CLICK HIJACK');">like so</a>
            eos
            expect(sanitize_html(text)).to be_html_safe
          end
        end
      end
    end
  end
end
