class Api::V1::ClusteredProjectsController < ApiController
  def index
    result = [{
      name: "Latin America and Caribbean",
      total_people: 688157,
      lat: -2.4601812,
      lng: -59.4140625,
      clustered: true,
      per_sector: [{
        slug: "econ",
        color: "#000",
        people: 3500
      }, {
        slug: "educ",
        color: "#333",
        people: 2500
      }, {
        slug: "emer",
        color: "#888",
        people: 1500
      }, {
        slug: "heal",
        color: "#aaa",
        people: 500
      }]
    }, {
      name: "West and South Africa",
      total_people: 1688157,
      lat: 7.7109917,
      lng: 20.0390625,
      clustered: false,
      per_sector: [{
        slug: "econ",
        color: "#000",
        people: 190500
      }, {
        slug: "educ",
        color: "#333",
        people: 102500
      }, {
        slug: "emer",
        color: "#888",
        people: 100500
      }, {
        slug: "heal",
        color: "#aaa",
        people: 5000
      }]
    }]
    render json: result
  end
end

