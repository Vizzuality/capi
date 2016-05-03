class Donation < CartoDb

  STRING_COLS = [:city, :confirmation, :country, :country_iso,
                 :gift_id, :nickname, :state, :sustainer]
  ARRAY_COLS = [:countries, :sectors]
  NUMBER_COLS = [:amount]
  DATE_COLS = [:date]
  BOOLEAN_COLS = [:historical_donation]

  COLUMNS = NUMBER_COLS + STRING_COLS + DATE_COLS + BOOLEAN_COLS + ARRAY_COLS

  attr_reader *COLUMNS

  def initialize(hsh)
    COLUMNS.each do |col|
      instance_variable_set("@#{col.to_s}", hsh[col.to_s])
    end
  end

  private

  def self.formatted_value col, value
    if STRING_COLS.include?(col)
      "'#{value}'"
    elsif NUMBER_COLS.include?(col)
      value
    elsif DATE_COLS.include?(col)
      "'#{Date.parse(value)}'"
    elsif ARRAY_COLS.include?(col)
      "ARRAY[#{value.split(",").map{|t| "'#{t}'"}.join(",")}]"
    elsif BOOLEAN_COLS.include?(col)
      false
    else
      nil
    end
  end

  def self.the_geom_val(record)
    if record["lat"].present? && record["lng"].present?
      "ST_SetSRID(ST_MakePoint(#{record["lng"]}, #{record["lat"]}), 4326)"
    elsif record["state"].present?
      %Q(
        cdb_geocode_namedplace_point('#{record["city"]}',
                                     '#{record["state"]}',
                                     '#{record["country"]}')
      )
    else
      %Q(
        cdb_geocode_namedplace_point('#{record["city"]}',
                                     '#{record["country"]}')
      )
    end
  end

  def self.table_name
    "donors_test"
  end
end
