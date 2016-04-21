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

    def create_in_batch(records)
      send_query(create_in_batch_query(records))
    end

    private

    def list_query
      %Q(
      SELECT #{columns.join(", ")} FROM #{table_name}
      WHERE #{columns.map{|c| "#{c} IS NOT NULL"}.join(" AND ")}
      ORDER BY #{order_column}
      )
    end

    def create_in_batch_query records
      values = []
      records.each do |r|
        row = []
        row << the_geom_val(r)
        columns.each do |col|
          row << formatted_value(col.to_sym, r[col])
        end
        values << "(#{row.compact.join(", ")})" unless row.compact.empty?
      end
      insert_header + values.join(", ")
    end

    def insert_header
      %Q(
        INSERT INTO #{table_name} (the_geom, #{columns.join(", ")})
        VALUES
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
      self::COLUMNS.map(&:to_s)
    end

    def order_column
      "name"
    end

    def the_geom_val records=nil
      nil
    end
  end
end
