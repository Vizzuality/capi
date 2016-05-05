class LayerSerializer < ActiveModel::Serializer
  attributes :slug, :name, :category, :geo_query, :geo_cartocss,
    :layer_type, :legend_type, :number_of_buckets, :sql_template,
    :active, :legend, :table_name, :domain, :timeline, :start_date,
    :end_date


  def domain
    [
      object.start_date,
      object.end_date
    ]
  end

  def timeline
    {
      speed: object.timeline_speed,
      interval: {
        unit: object.timeline_int_unit,
        count: object.timeline_int_count
      }
    }
  end
end

