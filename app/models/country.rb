class Country < CartoDb

  COLUMNS = [:iso, :name]

  attr_reader *COLUMNS

  def initialize(hsh)
    COLUMNS.each do |col|
      instance_variable_set("@#{col.to_s}", hsh[col.to_s])
    end
  end

  def self.cached_all
    Rails.cache.fetch(cache_key, expires_in: 20.days) do
      Country.all
    end
  end

  def self.cache_key
    "countries"
  end

  def self.fetch_country_for lat, lng
    puts country_query(lat, lng)
    send_query(country_query(lat, lng))["rows"]
  end

  def self.country_query lat, lng
    %(
      SELECT iso, name
      FROM #{table_name} AS countries
      WHERE ST_CONTAINS(countries.the_geom, ST_SetSRID(ST_MakePoint(
      #{lng}, #{lat}), 4326))
    )
  end
  private

  def self.table_name
    "borders"
  end
end
