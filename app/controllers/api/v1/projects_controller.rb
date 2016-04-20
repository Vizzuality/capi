class Api::V1::ProjectsController < ApiController
  def index
    @result = {
      "location": {
        "iso": "PRT",
        "name": "Portugal"
      },
      "number_of_projects": 3,
      "sectors": [
        {
          "slug": "water",
          "name": "Water and Sanitation"
        }
      ],
      "people_reached": 5056,
      "women_and_girls_total": 3792,
      "men_total": 1264
    }
    render json: @result
  end
end
