require_dependency 'projects/country'
class Api::V1::ProjectsLayerController < ApiController
  def index
    result = if params[:zoom] && params[:zoom].to_i < 4
               Projects::Clustered.new(params).fetch
             else
               Projects::Country.new(params).fetch
             end
    render json: result
  end
end

