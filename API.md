# KarPage API

## Cars

### Create

```
POST /api/cars/:id
{
  "car": {
    "year": "2015",
    "make_name": "Audi",
    "car_model_name": "R8",
    "description": "",
    "first": true,
    "current": false,
    "past": false,
    "sorting": 1,
    "photos_attributes": [
      <photo_attributes>, <photo_attributes>, ...
    ],
    parts_attributes: [
      <part_attributes>, <part_attributes>, ...
    ]
  }
}
```

## Car Parts / Build Lists

### Create

```
POST /api/cars/:car_id/parts
{
  "car_part": {
    "type": 'Wheel', 
    "manufacturer": 'Michelin', 
    "model": 'F500', 
    "price": 500,
    photo_attributes: <photo_attributes>
  }
}
```

### Update

Same parameters as `Create`.

```
PUT /api/cars/:car_id/parts/:id
```
