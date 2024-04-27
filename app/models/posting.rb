class Posting < ApplicationRecord

  belongs_to :author,    class_name: 'User', foreign_key: 'user_id'
  belongs_to :editor,    class_name: 'User', foreign_key: 'editor_id'

  # What this method returns? 'Question' or some weird '#0_' or 'not include <img' or hash?
  def article_with_image
    return type if type != 'Article'

    figure_start = body.index('<figure')
    figure_end = body.index('</figure>')
    return "#{figure_start}_#{figure_end}" if figure_start.nil? || figure_end.nil?

    # magic numbers.. better to use length of `</figure>` ?
    image_tags = body[figure_start...figure_end + 9]
    return 'not include <img' unless image_tags.include?('<img')

    # better to use some parser. like:
    # page = Nokogiri::HTML(body)
    # page.css('img').collect(&:to_s)[0]

    posting_image_params(image_tags)
  end

  private

  def posting_image_params(html)
    # user inputs should be sanitized
    tag_parse = -> (image, att) { image.match(/#{att}="(.+?)"/) }
    tag_attributes = {}

    %w[alt src data-image].each do |attribute|
      data = tag_parse.(html, attribute)
      unless data.nil?
        tag_attributes[attribute] = data[1] unless data.size < 2
      end
    end
    # tag_parse
    tag_attributes
  end
end
