{
  'BMW': '',
  'MOPAR': 'Dodge, Chrysler, Srt, Srt8, mopar',
  'WRX': 'Subaru, wrx',
  'MUSTANG': '',
  'CAMARO': '',
  'JEEP': '',
  'TRUCKS': 'GMC, Tundra, Ram, Raptor, Silverado, F150, F-150, C10, C-10, 4Runner, Pickup, Hummer, b2200, Hilux',
  'JDM': 'Nissan, Mitsubishi, Honda, Lexus, Acura, Mazda, Infiniti, Supra',
  'EXOTIC': 'Ferrari, Lamborghini, McLaren, Pagani'
}.each do |name, words|
  Filter.create(name: name, words: words) unless Filter.exists?(name: name)
end
Filter.create(name: 'CLASSIC', words: '', type: 'FilterClassicCar') unless Filter.exists?(name: 'CLASSIC')

%w[monday tuesday wednesday thursday friday saturday sunday].each do |day|
  PostChannel.where(name: day).first_or_create!
end
