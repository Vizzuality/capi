class Country
  include ActiveModel::Serialization

  attr_reader :iso, :name

  def initialize(iso, name)
    @iso = iso
    @name = name
  end
end
