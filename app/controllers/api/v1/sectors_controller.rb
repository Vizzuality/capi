class Api::V1::SectorsController < ApiController
  def index
    @sectors = Rails.cache.fetch(cache_key, expires_in: 5.days) do
      Sector.all
    end
    render json: @sectors, each_serializer: SectorSerializer
  end

  private

  def cache_key
    "sectors"
  end
end
