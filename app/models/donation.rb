class Donation < CartoDb

  STRING_COLS = [:city, :confirmati, :countries, :country, :country_iso,
                 :gift_id, :nickname, :sectors, :state, :sustainer]
  NUMBER_COLS = [:amount]
  DATE_COLS = [:date]

  COLUMNS = NUMBER_COLS + STRING_COLS + DATE_COLS

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
    else
      nil
    end
  end

  def self.table_name
    "donors_test"
  end
end
