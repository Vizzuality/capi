class Api::V1::ClusteredProjectsController < ApiController
  def index
    result = if params[:zoom] && params[:zoom].to_i >= 4
               [{
                 name: "Latin America and Caribbean",
                 total_people: 688_157,
                 lat: -2.4601812,
                 lng: -59.4140625,
                 clustered: true,
                 bucket: 3,
                 per_sector: [{
                   slug: "food",
                   color: "#8C8778",
                   people: 105_500
                 }, {
                   slug: "econ",
                   color: "#FDB02A",
                   people: 103_500
                 }, {
                   slug: "educ",
                   color: "#9AA78C",
                   people: 92_500
                 }]
               }, {
                 name: "North America",
                 total_people: 1_688_157,
                 lat: 42.0329743,
                 lng: -100.1953125,
                 clustered: true,
                 bucket: 2,
                 per_sector: [{
                   slug: "food",
                   color: "#8C8778",
                   people: 805_500
                 }, {
                   slug: "econ",
                   color: "#FDB02A",
                   people: 635_500
                 }, {
                   slug: "educ",
                   color: "#9AA78C",
                   people: 502_500
                 }]
               }, {
                 name: "Asia",
                 total_people: 10_688_157,
                 lat: 32.8426736,
                 lng: 96.3281250,
                 clustered: true,
                 bucket: 1,
                 per_sector: [{
                   slug: "food",
                   color: "#8C8778",
                   people: 8_105_500
                 }, {
                   slug: "econ",
                   color: "#FDB02A",
                   people: 5_950_500
                 }, {
                   slug: "educ",
                   color: "#9AA78C",
                   people: 3_992_500
                 }]
               }]
             else
               [{
                 name: "Australia",
                 total_people: 3_188_157,
                 lat: -26.4312281,
                 lng: 140.9765625,
                 clustered: false,
                 bucket: 1,
                 per_sector: [{
                   slug: "educ",
                   color: "#9AA78C",
                   people: 1_222_500
                 }, {
                   slug: "emer",
                   color: "#EBCA5F",
                   people: 999_500
                 }, {
                   slug: "heal",
                   color: "#ABD293",
                   people: 500_500
                 }, {
                   slug: "econ",
                   color: "#FDB02A",
                   people: 400_500
                 }, {
                   slug: "educ",
                   color: "#9AA78C",
                   people: 300_500
                 }, {
                   slug: "wate",
                   color: "#9DCED6",
                   people: 200_500
                 }]
               }, {
                 name: "West and South Africa",
                 total_people: 1_688_157,
                 lat: 7.7109917,
                 lng: 20.0390625,
                 clustered: false,
                 bucket: 2,
                 per_sector: [{
                   slug: "econ",
                   color: "#FDB02A",
                   people: 990_500
                 }, {
                   slug: "food",
                   color: "#8C8778",
                   people: 602_500
                 }, {
                   slug: "emer",
                   color: "#EBCA5F",
                   people: 500_500
                 }, {
                   slug: "clim",
                   color: "#92b2d7",
                   people: 400_500
                 }, {
                   slug: "educ",
                   color: "#9AA78C",
                   people: 300_500
                 }, {
                   slug: "wate",
                   color: "#9DCED6",
                   people: 200_500
                 }]
               }]
             end
    render json: result
  end
end

