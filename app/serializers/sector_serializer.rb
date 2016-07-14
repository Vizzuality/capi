class SectorSerializer < ActiveModel::Serializer
  attributes :slug, :name, :filter_for_projects, :color
end
