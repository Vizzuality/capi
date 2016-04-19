class Api::V1::CountriesController < ApiController
  def index
    @countries = Country.all
    render json: @countries, each_serializer: CountrySerializer
  end
end
