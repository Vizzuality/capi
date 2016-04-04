class Api::V1::SectorsController < ApiController
  def index
    @result = [
      Sector.new("health-and-safety", "Health and Safety"),
      Sector.new("water-and-sanitation", "Water and Sanitation")
    ]
    render json: @result, each_serializer: SectorSerializer
  end
end
