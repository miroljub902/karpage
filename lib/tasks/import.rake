# frozen_string_literal: true

namespace :import do
  task makes_models: :environment do
    # {
    #   2017 => {
    #     'Audi' => {
    #       'R8' => ['Trim 1', 'Trim 2', ...]
    #     }
    #   }
    # }
    makes = {}
    # models = { 'Make' => { 'Model' => 'Record...' } }
    models = {}

    require 'progress_bar'
    csv_file = Rails.root.join('db/autodb.csv')
    progress = ProgressBar.new(`cat #{csv_file}|wc -l`.strip.to_i - 1)

    CSV.foreach(csv_file, headers: true) do |row|
      makes[row['make']] ||= Make.where('name ILIKE ?', row['make']).first_or_initialize(name: row['make'])
      make = makes[row['make']]
      make.official = true
      make.save! if make.changed?

      models[row['make']] ||= {}
      models[row['make']][row['model']] ||=
        make.models.where('name ILIKE ?', row['model']).first_or_initialize(name: row['model'])
      model = models[row['make']][row['model']]
      model.official = true
      model.save! if model.changed?

      trim = model.trims.where('name ILIKE ? AND year = ?', row['trim'], row['year'].to_i)
                  .first_or_initialize(name: row['trim'], year: row['year'].to_i)
      trim.official = true
      trim.save!(validate: false) if trim.changed?

      progress.increment!
    end
  end
end
