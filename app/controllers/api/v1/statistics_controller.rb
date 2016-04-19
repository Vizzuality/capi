class Api::V1::StatisticsController < ApiController
  def index
    @result = Statistics.new(stats_params).fetch
    render json: @result
  end

  private

  def stats_params
    params.permit(:start_date, :end_date, :sectors_slug, :countries_slug)
  end
end
