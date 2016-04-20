class Api::V1::DonationsController < ApiController
  def index
    @result = {
      "name": "Name of donation",
      "location": {
        "iso": "PRT",
        "name": "Portugal"
      },
      "total_funds": 160000,
      "sectors": [
        {
          "slug": "water",
          "name": "Water and Sanitation"
        }
      ],
      "countries": [
        {
          "iso": "PRT",
          "name": "Portugal"
        }
      ]
    }
    render json: @result
  end

  def create
    Donation.create_in_batch(params["donations"])
    head :created
  end
end
