class Api::V1::ClusteredProjectsController < ApiController
  def index
    result = if params[:zoom] && params[:zoom].to_i < 4
               ClusteredProjects.new(params).fetch
             else
               CountryProjects.new(params).fetch
             end
    render json: result
  end
end

