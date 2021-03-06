class CartoDb
  include ActiveModel::Serialization

  alias :read_attribute_for_serialization :send

  class << self
    def model_name
      @_model_name ||= ActiveModel::Name.new(self)
    end

    def send_query query, get=true
      api_call = Cartowrap::API.new
      result = if get
                 api_call.send_query(query)
               else
                 api_call.post_query(query)
               end
      JSON.parse(result)
    end

    def all
      results = send_query(list_query)
      parse(results)
    end

    def create_in_batch(records)
      result = send_query(create_in_batch_query(records), false)
      if result["rows"]
        send_query(update_country_iso_query)
      end
      result
    end

    def find gift_id
      send_query(find_by_query(gift_id))["rows"].first
    end

    private

    def find_by_query gift_id
      %Q(
        SELECT #{columns.join(", ")},
        ST_Y(the_geom) AS lat, ST_X(the_geom) AS lng
        FROM #{table_name}
        WHERE gift_id = '#{gift_id}'
      )
    end

    def list_query
      %Q(
      SELECT #{columns.join(", ")} FROM #{table_name}
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
