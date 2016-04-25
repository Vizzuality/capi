class Api::V1::CountriesController < ApiController
  def index
    @countries = Rails.cache.fetch(cache_key, expires_in: 5.days) do
      Country.all
    end
    render json: @countries, each_serializer: CountrySerializer
  end

  private

  def cache_key
    "countries"
  end
end
