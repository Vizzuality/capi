class Country
  include ActiveModel::Serialization

  attr_reader :iso, :name

  def initialize(iso, name)
    @iso = iso
    @name = name
  end

  class << self
    TABLE_NAME = "borders_care"

    def all
      api_call = Cartowrap::API.new
      results = api_call.send_query(list_query)
      parse_data(results)
    end

    private

    def list_query
      <<-SQL
        SELECT iso, name
        FROM #{TABLE_NAME}
        WHERE iso IS NOT NULL AND name IS NOT NULL
        ORDER BY name
      SQL
    end

    def parse_data data
      JSON.parse(data)["rows"].map do |row|
        Country.new(row["iso"], row["name"])
      end
    end
  end
end
