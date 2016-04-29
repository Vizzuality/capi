class Layer < CartoDb
  COLUMNS = [:slug, :name, :category, :geo_query, :geo_cartocss,
             :layer_type, :legend_type, :number_of_buckets, :sql_template,
             :active, :legend, :table_name, :layer_type, :date_col]

  attr_reader *COLUMNS
  attr_reader :start_date, :end_date

  def initialize(hsh)
    COLUMNS.each do |col|
      instance_variable_set("@#{col.to_s}", hsh[col.to_s])
    end
  end

  def set_limit_dates
    result = Layer.send_query(limit_dates_query)["rows"].try(:first)
    return unless result
    @start_date = result["start_date"]
    @end_date = result["end_date"]
  end

  def limit_dates_query
    %Q(
      SELECT MIN(#{@date_col}) AS start_date, MAX(#{@date_col}) AS end_date
      FROM #{@table_name}
    )
  end

  private

  def self.parse data
    return [] unless data["rows"]
    data["rows"].map do |row|
      layer = self.new(row)
      layer.set_limit_dates
      layer
    end
  end

  def self.table_name
    "table_spec"
  end
end
