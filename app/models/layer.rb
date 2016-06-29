class Layer < CartoDb
  COLUMNS = [:slug, :name, :category, :geo_query, :geo_cartocss,
             :layer_type, :legend_type, :number_of_buckets, :sql_template,
             :active, :legend, :table_name, :date_col,
             :timeline_int_count, :timeline_int_unit, :timeline_speed]

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
    begin
      @start_date, @end_date = [
        Date.parse(result["start_date"]),
        Date.parse(result["end_date"])
      ]
    rescue
      if result["start_date"].is_a?(Fixnum) && result["end_date"].is_a?(Fixnum)
        @start_date, @end_date = [
          Date.parse("1/1/#{result["start_date"]}"),
          Date.parse("31/12/#{result["end_date"]}"),
        ]
      end
    end
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
    "table_spec_test"
  end
end
