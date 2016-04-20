# API Documentation

[Documentation can be found here.](http://docs.careusa.apiary.io)

## Development progress

- [x] GET /api/v1/countries
- [x] GET /api/v1/sectors
- [x] GET /api/v1/layers
- [ ] GET /api/v1/layers?category
- [x] GET /api/v1/statistics?start_date=start_date&end_date=end_date&sectors_slug=sectors_slug&countries_iso=countries_iso
- [x] GET /api/v1/projects?lat=lat&lng=lng&layer_id=layer_id&start_date=start_date&end_date=end_date&sectors_slug=sectors_slug
- [ ] POST /api/v1/donations
- [ ] GET /api/v1/donations?lat=lat&lng=lng&layer_id=layer_id&start_date=start_date&end_date=end_date&sectors_slug=sectors_slug&countries_iso=countries_iso

## Dependencies

* Ruby 2.2.4
* Rails 5.0.0.beta3
* PostgreSQL

## Setting up                     

1- Clone the Application

`git clone git@github.com:Vizzuality/capi.git`

2- Run bundle
 
`bundle install`

3- Create your database (default username & password are both **postgres**)
 
`rails db:create`

4- Run migrations

`rails db:migrate`

5- Start your server

`rails server`
