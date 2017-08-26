# Kar Page

## Getting Started

1. Install dependencies: `bundle install`
2. Copy `example.env` to `.env.local|development|test` and edit
3. Create database: `rake db:create`
4. Run migrations: `rake db:migrate`
5. Seed database: `rake db:seed`
6. Profit: `bin/rails s`

## Postmark Templates

The app uses Postmark to send transactional e-mails. 
The `example.env` file has the variables that need to be set.

## Deployment

1. `mina deploy`

## Development

Run `overcommit --install && overcommit --sign` or make sure to run rubocop before every commit.

## Docker

1. Create `.env.docker.local`
2. Build image: `docker-compose build`
3. Create database: `docker-compose run web rake db:create`
4. Run migrations: `docker-compose run web rake db:migrate`
5. Run:
    1. `docker-compose up postgres redis sidekiq`
    2. `docker-compose run -p 3000:3000 -p 1234:1234 -v <app local dir>:/app web`
