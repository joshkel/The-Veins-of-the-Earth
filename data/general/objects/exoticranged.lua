--Veins of the Earth
--Zireael 2013-2014

local Talents = require "engine.interface.ActorTalents"

--Exotic ranged weapons

newEntity{
    define_as = "BASE_EXOTIC_RANGED",
    slot = "MAIN_HAND",
    slot_forbid = "OFF_HAND",
    type = "weapon",
    exotic = true,
    require = { talent = { Talents.T_EXOTIC_WEAPON_PROFICIENCY }, },
    egos = "/data/general/objects/properties/weapons.lua", egos_chance = { prefix=30, suffix=70},
}

newEntity{ base = "BASE_EXOTIC_RANGED",
    define_as = "BASE_HANDXBOW",
    slot = "MAIN_HAND",
    slot_forbid = "OFF_HAND",
    type = "weapon", subtype="crossbow",
    image = "tiles/crossbow_light.png",
    display = "}", color=colors.SLATE,
    encumber = 2,
    rarity = 10,
    combat = { sound = "actions/arrow", sound_miss = "actions/arrow", },
    name = "a generic hand crossbow",
    desc = "A normal trusty hand crossbow.\n\n Damage 1d4. Threat range 19-20. Range 3.",
}

newEntity{ base = "BASE_HANDXBOW",
    name = "hand crossbow",
    level_range = {1, 10},
    cost = 100,
    combat = {
        dam = {1,4},
        threat = 1,
        range = 3,
    },
}

