class Country < CartoDb

  attr_reader :iso, :name

  def initialize(hsh)
    @iso = hsh["iso"]
    @name = hsh["name"]
  end


  private

  def self.columns
    ["iso", "name"]
  end

  def self.table_name
    "borders_care"
  end
end
