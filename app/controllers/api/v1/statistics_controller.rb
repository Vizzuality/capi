class Api::V1::StatisticsController < ApiController
  def index
    @result = DonationsStatistics.new(stats_params).fetch
    @result.merge!(ProjectsStatistics.new(stats_params).fetch)
    @result.merge!(StoriesStatistics.new().fetch)
    render json: @result
  end

  private

  def stats_params
    params.permit(:start_date, :end_date, sectors_slug: [],
                  countries_iso: [])
  end
end
