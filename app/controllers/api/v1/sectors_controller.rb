class Api::V1::SectorsController < ApiController
  def index
    @sectors = Sector.all
    render json: @sectors, each_serializer: SectorSerializer
  end
end
