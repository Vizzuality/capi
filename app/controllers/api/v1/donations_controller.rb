class Api::V1::DonationsController < ApiController
  def index
    @result = DonationsSummary.new(filtering_params).fetch
    render json: @result
  end

  def create
    result = Donation.create_in_batch(params["donations"])
    if result["rows"]
      head :created
    else
      render json: result, status: :bad_request
    end
  end

  def distribution
    @result = DonationsDistribution.new(filtering_params).fetch
    render json: @result
  end

  def show
    @result = Donation.find(params[:id])
    render json: @result || {}
  end

  private

  def filtering_params
    params.permit(:lat, :lng, :start_date, :end_date, :layer_id,
                  :zoom, sectors_slug: [], countries_slug: [])
  end
end
