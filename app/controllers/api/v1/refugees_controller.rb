class Api::V1::RefugeesController < ApiController
  def index
    @result = RefugeesSummary.new(refugees_params).fetch
    render json: @result
  end

  private

  def refugees_params
    params.permit(:lat, :lng, :year)
  end
end
