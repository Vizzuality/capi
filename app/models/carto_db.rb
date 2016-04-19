class CartoDb
  include ActiveModel::Serialization

  class << self
    def all
      api_call = Cartowrap::API.new
      results = api_call.send_query(list_query)
      parse_data(results)
    end

    private

    def list_query
      %Q(
      SELECT #{columns.join(", ")} FROM #{table_name}
      WHERE #{columns.map{|c| "#{c} IS NOT NULL"}.join(" AND ")}
      ORDER BY #{order_column}
      )
    end

    def parse_data data
      JSON.parse(data)["rows"].map do |row|
        self.new(row)
      end
    end

    def table_name
      self.to_s.downcase
    end

    def columns
      raise "Needs to be implemented"
    end

    def order_column
      "name"
    end
  end
end
