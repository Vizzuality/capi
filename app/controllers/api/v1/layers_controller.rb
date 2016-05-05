class Api::V1::LayersController < ApiController
  def index
    @layers = Layer.all
    render json: @layers, each_serializer: LayerSerializer
  end
end
