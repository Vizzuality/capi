class Api::V1::ClusteredProjectsController < ApiController
  def index
    result = [{
      name: "Latin America and Caribbean",
      total_people: 688157,
      lat: -2.4601812,
      lng: -59.4140625,
      clustered: true,
      per_sector: [{
        slug: "food",
        color: "#000",
        people: 5500
      }, {
        slug: "econ",
        color: "#333",
        people: 3500
      }, {
        slug: "educ",
        color: "#555",
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
      name: "North America",
      total_people: 1688157,
      lat: 42.0329743,
      lng: -100.1953125,
      clustered: true,
      per_sector: [{
        slug: "food",
        color: "#000",
        people: 105500
      }, {
        slug: "econ",
        color: "#333",
        people: 35500
      }, {
        slug: "educ",
        color: "#555",
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
      name: "Asia",
      total_people: 10688157,
      lat: 32.8426736,
      lng: 96.3281250,
      clustered: true,
      per_sector: [{
        slug: "food",
        color: "#000",
        people: 1105500
      }, {
        slug: "econ",
        color: "#333",
        people: 95500
      }, {
        slug: "educ",
        color: "#555",
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
      name: "Australia",
      total_people: 188157,
      lat: -26.4312281,
      lng: 140.9765625,
      clustered: false,
      per_sector: [{
        slug: "educ",
        color: "#555",
        people: 22500
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
      }]
    }]
    render json: result
  end
end

