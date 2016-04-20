class Layer < CartoDb

  attr_reader :slug, :name, :category, :geo_query, :geo_cartocss,
    :layer_type, :legend_type, :number_of_buckets

  def initialize(hsh)
    @slug = hsh["slug"]
    @name = hsh["name"]
    @category = hsh["category"]
    @geo_query = hsh["geo_query"]
    @geo_cartocss = hsh["geo_cartocss"]
    @layer_type = hsh["layer_type"]
    @legend_type = hsh["legend_type"]
    @number_of_buckets = hsh["number_of_buckets"]
  end


  private

  def self.columns
    ["slug", "name", "category", "geo_query", "geo_cartocss", "layer_type",
      "legend_type", "number_of_buckets"]
  end

  def self.table_name
    "table_spec"
  end
end
