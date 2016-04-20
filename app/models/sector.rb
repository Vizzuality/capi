class Sector < CartoDb
  COLUMNS = [:slug, :name]

  attr_reader *COLUMNS

  def initialize(hsh)
    COLUMNS.each do |col|
      instance_variable_set("@#{col.to_s}", hsh[col.to_s])
    end
  end
end
