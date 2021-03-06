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
    return "NULL" unless value.present?
    if STRING_COLS.include?(col)
      if col == :country && "USA" == value
        value = "United States"
      end
      "#{ActiveRecord::Base::sanitize(value)}"
    elsif NUMBER_COLS.include?(col)
      value
    elsif DATE_COLS.include?(col)
      "'#{Date.parse(value)}'"
    elsif ARRAY_COLS.include?(col)
      "ARRAY[#{value.split(",").map{|t| "#{ActiveRecord::Base::sanitize(t)}"}.join(",")}]"
    elsif BOOLEAN_COLS.include?(col)
      value
    else
      "NULL"
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

  def self.update_country_iso_query
    %Q(
      UPDATE #{table_name}
      SET country_iso = borders.iso_a3
      FROM #{Country.table_name} AS borders
      WHERE (borders.name = #{table_name}.country OR borders.admin = #{table_name}.country)
      AND #{table_name}.country_iso IS NULL
    )
  end

  def self.table_name
    ENV["DONORS_TABLE"] || "donors_test"
  end
end
