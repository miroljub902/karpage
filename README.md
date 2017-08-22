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

Run `overcommit --sign` or make sure to run rubocop before every commit.

