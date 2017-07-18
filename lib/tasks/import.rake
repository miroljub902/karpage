namespace :import do
  task makes_models: :environment do
    CSV.foreach(Rails.root.join('db/autodb.csv'), headers: true) do |row|
      make = Make.where('name ILIKE ?', row['make']).first_or_initialize(name: row['make'])
      make.official = true
      make.save! if make.changed?
      model = make.models.where('name ILIKE ?', row['model']).first_or_initialize(name: row['model'])
      model.official = true
      model.save! if model.changed?
      model.trims.where('name ILIKE ?', row['trim']).first_or_create!(name: row['trim'], official: true)
    end
  end
end
