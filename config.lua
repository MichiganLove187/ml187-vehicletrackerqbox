Config = {}

-- Items
Config.Items = {
    tracker = 'vehicletracker',
    tablet = 'vehicletrackertablet',
    scanner = 'vehicletrackerscanner'
}

-- Tracker settings
Config.TrackerLifespan = 30 -- Days before tracker is automatically removed from database
Config.ScanDistance = 3.0 -- Distance in meters to scan for vehicles
Config.PlaceDistance = 2.5 -- Distance in meters to place tracker

-- UI settings
Config.NotifyPosition = 'center-right'
Config.NotifyDuration = 7000

-- Blip settings
Config.Blip = {
    sprite = 161,
    color = 1,
    scale = 2.5,
    alpha = 250,
    display = 2,
    shortRange = false
}

-- Progress bar durations (in ms)
Config.ProgressDuration = {
    connect = 2000,
    scan = 6000,
    place = 6000,
    remove = 6000
}

-- Animations
Config.Animations = {
    tablet = {
        dict = 'amb@code_human_in_bus_passenger_idles@female@tablet@base',
        clip = 'base',
        flag = 49
    },
    mechanic = {
        dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
        clip = 'machinic_loop_mechandplayer',
        flag = 1
    }
}

-- Props
Config.Props = {
    tablet = {
        model = `prop_cs_tablet`,
        pos = vec3(0.03, 0.002, -0.0),
        rot = vec3(10.0, 160.0, 0.0)
    },
    scanner = {
        model = `w_am_digiscanner`,
        pos = vec3(0.06, 0.03, -0.1),
        rot = vec3(10.0, 190.0, 0.0)
    },
    tracker = {
        model = `prop_prototype_minibomb`,
        pos = vec3(0.1, 0.03, -0.0),
        rot = vec3(10.0, 160.0, 0.0)
    }
}

-- Sounds
Config.Sounds = {
    success = {
        name = 'Hack_Success',
        dict = 'DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS'
    },
    alert = {
        name = 'TIMER_STOP',
        dict = 'HUD_MINI_GAME_SOUNDSET'
    },
    locate = {
        name = '10_SEC_WARNING',
        dict = 'HUD_MINI_GAME_SOUNDSET'
    }
}
