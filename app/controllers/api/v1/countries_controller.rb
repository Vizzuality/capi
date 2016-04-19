class Api::V1::CountriesController < ApiController
  def index
    @result = Country.all
    render json: @result, each_serializer: CountrySerializer
  end
end
