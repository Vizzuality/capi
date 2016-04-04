class Sector
  include ActiveModel::Serialization

  attr_reader :slug, :name

  def initialize(slug, name)
    @slug = slug
    @name = name
  end
end
