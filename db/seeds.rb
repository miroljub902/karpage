{
  "BMW": "",
  "MOPAR": "Dodge, Chrysler, Srt, Srt8, mopar",
  "WRX": "Subaru, wrx",
  "MUSTANG": "",
  "CAMARO": "",
  "JEEP": "",
  "TRUCKS": "GMC, Tundra, Ram, Raptor, Silverado, F150, F-150, C10, C-10, 4Runner, Pickup, Hummer, b2200, Hilux",
  "JDM": "Nissan, Mitsubishi, Honda, Lexus, Acura, Mazda, Infiniti, Supra"
}.each do |name, words|
  Filter.create(name: name, words: words) if !Filter.exists?(name: name)
end

User.create(name: 'Psalmuel Aguilar', email:"psalmuelaguilar@gmail.com", password:'password', password_confirmation:'password')
