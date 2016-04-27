class Api::V1::DonationsController < ApiController
  def index
    @result = DonationsSummary.new(filtering_params).fetch
    render json: @result
  end

  def create
    Donation.create_in_batch(params["donations"])
    head :created
  end

  def distribution
    @result = DonationsDistribution.new(filtering_params).fetch
    render json: @result
  end

  private

  def filtering_params
    params.permit(:lat, :lng, :start_date, :end_dte, :layer_id,
                  :zoom, sectors_slug: [], countries_slug: [])
  end
end
