class Api::V1::CountriesController < ApiController
  def index
    @countries = Country.cached_all
    render json: @countries, each_serializer: CountrySerializer
  end
end
