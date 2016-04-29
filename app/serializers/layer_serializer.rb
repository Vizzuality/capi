class LayerSerializer < ActiveModel::Serializer
  attributes :slug, :name, :category, :geo_query, :geo_cartocss,
    :layer_type, :legend_type, :number_of_buckets, :start_date, :end_date
end

