class CartoDb
  include ActiveModel::Serialization

  class << self

    def send_query query
      api_call = Cartowrap::API.new
      JSON.parse(api_call.send_query(query))
    end

    def all
      results = send_query(list_query)
      parse(results)
    end

    def find filters
      results = send_query(filtered_query(filters))
      parse(results)
    end

    private

    def list_query
      %Q(
      SELECT #{columns.join(", ")} FROM #{table_name}
      WHERE #{columns.map{|c| "#{c} IS NOT NULL"}.join(" AND ")}
      ORDER BY #{order_column}
      )
    end

    def filtered_query filters
      raise "Neets to be implemented"
    end

    def parse data
      return [] unless data["rows"]
      data["rows"].map do |row|
        self.new(row)
      end
    end

    def table_name
      self.to_s.downcase.pluralize
    end

    def columns
      raise "Needs to be implemented"
    end

    def order_column
      "name"
    end
  end
end
