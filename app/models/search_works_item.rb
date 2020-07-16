# frozen_string_literal: true

##
# Utility class to fetch a SearchWorks item
class SearchWorksItem
  attr_reader :ckey
  def initialize(ckey)
    @ckey = ckey
  end

  def to_h
    {
      ckey: ckey,
      title: title,
    }.merge(media_fields)
  end

  def valid?
    title.present?
  end

  private

  def media_fields
    return {} unless media?

    { loan_period: '4 hours', media: 'true' }
  end

  def media?
    formats.include?('Video')
  end

  def formats
    document['format_main_ssim'] || []
  end

  def title
    document['title_full_display']
  end

  def document
    @document ||= begin
      JSON.parse(Faraday.get(url).body).dig('response', 'document')
    rescue => e
      Honeybadger.notify("SearchWorks request failed for #{url} with #{e}")
      {}
    end
  end

  def url
    "https://searchworks.stanford.edu/view/#{ckey}.json"
  end
end
