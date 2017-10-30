# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

Rails.application.config.assets.quiet = true

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.1'

# Add additional assets to the asset load path
Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'components')
Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'javascripts')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile << 'application.css' # There seems to be a bug which requires we add this
Rails.application.config.assets.precompile << /.*.(?:eot|svg|ttf|woff)$/
Rails.application.config.assets.precompile << 'splash.css'
