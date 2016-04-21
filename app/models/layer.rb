class Layer < CartoDb
  COLUMNS = [:slug, :name, :category, :geo_query, :geo_cartocss,
             :layer_type, :legend_type, :number_of_buckets, :sql_template,
             :active, :legend]

  attr_reader *COLUMNS

  def initialize(hsh)
    COLUMNS.each do |col|
      instance_variable_set("@#{col.to_s}", hsh[col.to_s])
    end
  end

  private

  def self.table_name
    "table_spec"
  end
end
