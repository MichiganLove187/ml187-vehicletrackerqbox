

Created BY ML187
a Vehicle Tracking script to keep track of all your cars!!!

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

2) Move all images from img/ folder to your inventory image folder. example qb-inventory/html/images

3) Run **sql/vehicle_trackers.sql** to create the DB table

## Notes
- Trackers records older than 30 days will be automatically deleted from DB table. If you want to change/stop this behaviour refer to onResourceStart event handler in server/server.lua
