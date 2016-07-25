class Api::V1::ProjectsController < ApiController
  def index
    @result = ProjectsSummary.new(projects_params).fetch
    render json: @result
  end

  private

  def projects_params
    params.permit(:iso, :year)
  end
end
