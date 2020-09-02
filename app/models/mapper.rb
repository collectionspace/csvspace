# frozen_string_literal: true

class Mapper < ApplicationRecord
  self.inheritance_column = :_type_disabled
  has_one_attached :config
  before_save :set_title
  validates :profile, presence: true
  validates :type, presence: true
  validates :version, presence: true
  validates :url, presence: true, uniqueness: true
  scope :select_options, ->(connection) { where("title LIKE ?", "#{connection.profile}%") }
  scope :profile_versions, -> {
    order('profile asc, version asc').pluck(:profile, :version).map { |m| m.join('-') }.uniq
  }

  def download
    config.attach(
      io: StringIO.new(HTTP.get(url).to_s),
      filename: "#{title}.json",
      content_type: 'application/json'
    )
    self.status = true
  end

  def found?
    status
  end

  def self.create_mapper(json)
    url_found = HTTP.get(json['url']).status.success?
    mapper = Mapper.find_or_create_by!(\
      profile: json['profile'], version: json['version'], type: json['type']
    ) do |m|
      logger.info "Creating mapper for: #{json.inspect}"
      m.url = json['url']
      m.status = url_found
    end
    if mapper.url != json['url']
      logger.info "Updating mapper for: #{json.inspect}"
      mapper.config.purge if mapper.config.attached?
      mapper.update(
        url: json['url'],
        status: url_found
      )
    end
    return mapper if mapper.config.attached? || !url_found

    mapper.download
  end

  def self.refresh
    mappers_url = Rails.configuration.mappers_url
    mappers_response = HTTP.get(mappers_url)
    return false unless mappers_response.status.success?

    begin
      JSON.parse(mappers_response.body.to_s)['mappers'].each do |m|
        create_mapper(m)
      rescue StandardError => e
        logger.error(e.message)
      end
    rescue JSON::ParserError => e
      logger.error(e.message)
    end
  end

  private

  def set_title
    self.title = "#{profile}-#{version}-#{type}"
  end
end
