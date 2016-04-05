class Api::V1::StatisticsController < ApiController
  def index
    @result = {
      total_donations: 168_300,
      total_funds: 1_773_000
    }
    render json: @result
  end
end
