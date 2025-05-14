

recreated BY ML187 --- ORIGINAL AUTHOR nitrou5 originally called qb-vehicle-tracker
https://github.com/nitrou5?tab=overview&from=2024-12-01&to=2024-12-31
a Vehicle Tracking script to keep track of all your cars!!!
NOW ALLOWS ONE TABLET TO TRACK ALL PLAYERS CARS

## Dependencies
- [ox_lib](https://github.com/overextended/ox_lib)

## Installation
1) Add the following items into your Ox_inventory:
```
-- Vehicle GPS Tracker
['vehicletracker'] = {
    label = 'Vehicle GPS Tracker',
    weight = 1000,
    description = 'A device placed to track a vehicle\'s location.',
    stack = false,
    close = true,
},

-- Vehicle Tracker Tablet
['vehicletrackertablet'] = {
    label = 'Vehicle Tracker Tablet',
    weight = 1000,
    description = 'Connects to a vehicle tracker to show it\'s location.',
    stack = false,
    close = true,
},

-- Vehicle Tracker Scanner
['vehicletrackerscanner'] = {
    label = 'Vehicle Tracker Scanner',
    weight = 1000,
    description = 'Scans a vehicle for existence of GPS tracker.',
    stack = false,
    close = true,
},

```

2) Move all images from img/ folder to your inventory image folder. example ox_inventory/web/images

3) Run **sql/vehicle_trackers.sql** to create the DB table

## Notes
- Trackers records older than 30 days will be automatically deleted from DB table. 
