class Sector < CartoDb
  COLUMNS = [:slug, :name, :filter_for_projects]

  attr_reader *COLUMNS

  def initialize(hsh)
    COLUMNS.each do |col|
      instance_variable_set("@#{col.to_s}", hsh[col.to_s])
    end
  end

  def self.cached_all
    Rails.cache.fetch(cache_key, expires_in: 20.days) do
      Sector.all
    end
  end

  def self.cache_key
    "sectors"
  end
end
