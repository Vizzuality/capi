class Api::V1::CountriesController < ApiController
  def index
    @result = [
      Country.new("PTR", "Portugal"),
      Country.new("SPA", "Spain")
    ]
    render json: @result, each_serializer: CountrySerializer
  end
end
