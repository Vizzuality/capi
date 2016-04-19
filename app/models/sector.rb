class Sector < CartoDb

  attr_reader :slug, :name

  def initialize(hsh)
    @slug = hsh["slug"]
    @name = hsh["name"]
  end

  private

  def self.columns
    ["slug", "name"]
  end

  def self.table_name
    "sectors_care"
  end
end
