Simple Sinatra application for searching Github repositories by owner name
======================

## Configuration
Configure application with following credentials in .env file:

* API_ENDPOINT — github graphql api
* TOKEN — github personal access token

Create .env.local file and override your settings

## Commands

### Build
```sh
docker-compose build app
```
### Run
```sh
docker-compose up -d app
```
### Test
```sh
docker-compose run -e APP_ENV=test --rm app rspec
```
### Rubocop
```sh
docker-compose run --rm app rubocop
```
