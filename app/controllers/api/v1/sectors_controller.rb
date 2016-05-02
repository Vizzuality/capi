class Api::V1::SectorsController < ApiController
  def index
    @sectors = Sector.cached_all
    render json: @sectors, each_serializer: SectorSerializer
  end
end
