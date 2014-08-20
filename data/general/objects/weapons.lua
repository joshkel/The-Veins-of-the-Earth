--Veins of the Earth
--Zireael 2013-2014

--Simple weapons
newEntity{
    define_as = "BASE_WEAPON",
    slot = "MAIN_HAND", offslot = "OFF_HAND",
    type = "weapon",
    egos = "/data/general/objects/properties/weapons.lua", egos_chance = { prefix=30, suffix=70},
}

newEntity{
    define_as = "BASE_WEAPON_TWOHANDED",
    slot = "MAIN_HAND", slot_forbid = "OFF_HAND",
    type = "weapon",
    egos = "/data/general/objects/properties/weapons.lua", egos_chance = { prefix=30, suffix=70},
}

newEntity{ base = "BASE_WEAPON",
    define_as = "BASE_DAGGER",
    type = "weapon", subtype="dagger",
    image = "tiles/dagger.png",
    display = "|", color=colors.SLATE,
    moddable_tile = resolvers.moddable_tile("dagger"),
    encumber = 3,
    rarity = 8,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A normal trusty dagger.\n\n Damage 1d4, threat range 19-20.",
    name = "iron dagger",
    level_range = {1, 10},
    cost = 5,
    light = true,
    combat = {
        dam = {1,4},
        threat = 1,
    },

}

newEntity{ base = "BASE_WEAPON",
    define_as = "BASE_SICKLE",
    type = "weapon", subtype = "sickle",
-- image = "tiles/sickle.png",
    display = "|", color=colors.SLATE,
    encumber = 2,
    rarity = 9,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    name = "sickle",
    desc = "A normal sickle.\n\n Damage 1d6.",
    level_range = {1, 10},
    cost = 6,
    light = true,
    combat = {
        dam = {1,6},
        threat = 1,
    },  
}

newEntity{ base = "BASE_WEAPON",
    define_as = "BASE_SSPEAR",
    slot = "MAIN_HAND", 
    type = "weapon", subtype="spear",
    image = "tiles/spear.png",
    display = "/", color=colors.BROWN,
    encumber = 10,
    rarity = 5,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A wooden short spear.\n\n Damage 1d6.",
    name = "short spear",
    level_range = {1, 10},
    cost = 1,
    simple = true,
    combat = {
        dam = {1,6},
    },   
}

newEntity{ base = "BASE_WEAPON",
    define_as = "BASE_HMACE",
    slot = "MAIN_HAND", offslot = "OFF_HAND",
    type = "weapon", subtype="mace",
    image = "tiles/mace.png",
    display = "\\", color=colors.SLATE,
    moddable_tile = resolvers.moddable_tile("mace"),
    encumber = 8,
    rarity = 5,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A heavy metal mace.\n\n Damage 1d8.",
    name = "heavy mace",
    level_range = {1, 10},
    cost = 12,
    simple = true,
    combat = {
        dam = {1,8},
    },
}

newEntity{ base = "BASE_WEAPON",
    define_as = "BASE_LMACE",
    slot = "MAIN_HAND", offslot = "OFF_HAND",
    type = "weapon", subtype="mace",
    image = "tiles/mace.png",
    display = "\\", color=colors.SLATE,
    moddable_tile = resolvers.moddable_tile("mace"),
    encumber = 4,
    rarity = 5,
    light = true,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A light metal mace.\n\n Damage 1d6.",
    name = "light mace",
    level_range = {1, 10},
    cost = 5,
    simple = true,
    combat = {
        dam = {1,6},
    },
}

newEntity{ base = "BASE_WEAPON",
    define_as = "BASE_CLUB",
    slot = "MAIN_HAND", offslot = "OFF_HAND",
    type = "weapon", subtype="club",
    image = "tiles/club.png",
    display = "\\", color=colors.SLATE,
    encumber = 3,
    rarity = 3,
    simple = true,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A wooden club.\n\n Damage 1d6.",
    name = "club",
    level_range = {1, 10},
    cost = 0,
    combat = {
        dam = {1,6},
    },
}

newEntity{ base = "BASE_WEAPON",
    define_as = "BASE_MSTAR",
    slot = "MAIN_HAND", offslot = "OFF_HAND",
    type = "weapon", subtype="morningstar",
    image = "tiles/newtiles/morningstar.png",
    display = "\\", color=colors.SLATE,
    encumber = 6,
    rarity = 5,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A metal morningstar.\n\n Damage 1d8.",
    name = "morningstar",
    level_range = {1, 10},
    cost = 8,
    simple = true,
    combat = {
        dam = {1,8},
    },
}


newEntity{ base = "BASE_WEAPON_TWOHANDED",
    define_as = "BASE_STAFF",
    slot = "MAIN_HAND", slot_forbid = "OFF_HAND",
    type = "weapon", subtype="staff",
    image = "tiles/staff.png",
    display = "\\", color=colors.BROWN,
    moddable_tile = resolvers.moddable_tile("staff"),
    encumber = 4,
    rarity = 2,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A wooden staff.\n\n Damage 1d6.",
    name = "quarterstaff",
    level_range = {1, 10},
    cost = 0,
    simple = true,
    combat = {
        dam = {1,6},
    },
}

--Martial weapons

newEntity{ base = "BASE_WEAPON",
    define_as = "BASE_LHAMMER",
    slot = "MAIN_HAND", offslot = "OFF_HAND",
    type = "weapon", subtype="hammer",
    image = "tiles/hammer.png",
    display = "\\", color=colors.SLATE,
    encumber = 4,
    rarity = 1,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A light metal hammer.\n\n Damage 1d4.",
    name = "light hammer",
    level_range = {1, 10},
    cost = 1,
    light = true,
    martial = true,
    combat = {
        dam = {1,4},
    },
}

newEntity{ base = "BASE_WEAPON",
    define_as = "BASE_HANDAXE",
    slot = "MAIN_HAND", offslot = "OFF_HAND",
    type = "weapon", subtype="handaxe",
    image = "tiles/handaxe.png",
    display = "\\", color=colors.SLATE,
    moddable_tile = resolvers.moddable_tile("handaxe"),
    encumber = 3,
    rarity = 3,
    light = true,
    martial = true,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A normal handaxe.\n\n Damage 1d6. Critical x3.",
    name = "handaxe",
    level_range = {1, 10},
    cost = 6,
    combat = {
        dam = {1,6},
        critical = 3,
    },
}

newEntity{ base = "BASE_WEAPON",
    define_as = "BASE_KUKRI",
    slot = "MAIN_HAND", offslot = "OFF_HAND",
    type = "weapon", subtype="kukri",
    image = "tiles/kukri.png",
    display = "|", color=colors.SLATE,
    encumber = 2,
    rarity = 5,
    light = true,
    martial = true,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A curved blade.\n\n Damage 1d4. Threat range 18-20.",
    name = "kukri",
    level_range = {1, 10},
    cost = 8,
    combat = {
        dam = {1,4},
        threat = 2,
    },
}

newEntity{ base = "BASE_WEAPON",
    define_as = "BASE_SHORTSWORD",
    slot = "MAIN_HAND", offslot = "OFF_HAND",
    type = "weapon", subtype="shortsword",
    image = "tiles/dagger.png",
    display = "|", color=colors.SLATE,
    moddable_tile = resolvers.moddable_tile("sword"),
    encumber = 2,
    rarity = 5,
    light = true,
    martial = true,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A curved short sword.\n\n Damage 1d6. Threat range 19-20.",
    name = "short sword",
    level_range = {1, 10},
    cost = 10,
    combat = {
        dam = {1,6},
        threat = 1,
    },
}

newEntity{ base = "BASE_WEAPON",
    define_as = "BASE_BATTLEAXE",
    slot = "MAIN_HAND", offslot = "OFF_HAND",
    type = "weapon", subtype="battleaxe",
    image = "tiles/battleaxe.png",
    display = "\\", color=colors.SLATE,
    moddable_tile = resolvers.moddable_tile("axe"),
    encumber = 12,
    rarity = 3,
    martial = true,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A normal battleaxe.\n\n Damage 1d6.",
    name = "battleaxe",
    level_range = {1, 10},
    cost = 5,
    combat = {
        dam = {1,6},
    },
}

newEntity{ base = "BASE_WEAPON",
    define_as = "BASE_SWORD",
    slot = "MAIN_HAND", offslot = "OFF_HAND",
    type = "weapon", subtype="sword",
    image = "tiles/longsword.png",
    display = "|", color=colors.SLATE,
    moddable_tile = resolvers.moddable_tile("sword"),
    encumber = 4,
    rarity = 5,
    martial = true,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A trusty sword.\n\n Damage 1d8. Threat range 18-20.",
    name = "long sword",
    level_range = {1, 10},
    cost = 15,
    combat = {
        dam = {1,8},
        threat = 2,
    },
}

newEntity{ base = "BASE_WEAPON",
    define_as = "BASE_FLAIL",
    slot = "MAIN_HAND", offslot = "OFF_HAND",
    type = "weapon", subtype="flail",
    image = "tiles/flail.png",
    display = "/", color=colors.SLATE,
    encumber = 5,
    rarity = 8,
    martial = true,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A metal flail. Damage 1d8.",
    name = "flail",
    level_range = {1, 10},
    cost = 8,
    combat = {
        dam = {1,8},
    },
}

newEntity{ base = "BASE_WEAPON",
    define_as = "BASE_RAPIER",
    slot = "MAIN_HAND", offslot = "OFF_HAND",
    type = "weapon", subtype="rapier",
    image = "tiles/rapier.png",
    display = "|", color=colors.SLATE,
    encumber = 2,
    rarity = 6,
    martial = true,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A metal rapier.\n\n Damage 1d6. Threat range 18-20.",
    name = "rapier",
    level_range = {1, 10},
    cost = 20,
    combat = {
        dam = {1,6},
        threat = 2,
    },
}

newEntity{ base = "BASE_WEAPON",
    define_as = "BASE_SCIMITAR",
    slot = "MAIN_HAND", offslot = "OFF_HAND",
    type = "weapon", subtype="scimitar",
    image = "tiles/scimitar.png",
    display = "|", color=colors.SLATE,
    encumber = 4,
    rarity = 7,
    martial = true,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    
    desc = "A metal scimitar.\n\n Damage 1d6. Threat range 18-20.",
    name = "scimitar",
    level_range = {1, 10},
    cost = 15,
    combat = {
        dam = {1,6},
        threat = 2,
    },
}

newEntity{ base = "BASE_WEAPON",
    define_as = "BASE_WARHAMMER",
    slot = "MAIN_HAND", offslot = "OFF_HAND",
    type = "weapon", subtype="hammer",
    image = "tiles/hammer.png",
    display = "\\", color=colors.SLATE,
    encumber = 5,
    rarity = 5,
    martial = true,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A metal warhammer.\n\n Damage 1d8. Critical x3.",
    name = "warhammer",
    level_range = {1, 10},
    cost = 12,
    combat = {
        dam = {1,8},
        critical = 3,
    },
}

--Two-handed weapons
newEntity{ base = "BASE_WEAPON_TWOHANDED",
    define_as = "BASE_FALCHION",
    slot = "MAIN_HAND",
    slot_forbid = "OFF_HAND",
    type = "weapon", subtype="falchion",
    image = "tiles/greatsword.png",
    display = "|", color=colors.SLATE,
    moddable_tile = resolvers.moddable_tile("greatsword"),
    encumber = 8,
    rarity = 10,
    martial = true,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A metal falchion.\n\n Damage 2d4. Threat range 18-20.",
    name = "falchion",
    level_range = {1, 10},
    cost = 75,
    combat = {
        dam = {2,4},
        threat = 2,
    },
}


newEntity{ base = "BASE_WEAPON_TWOHANDED",
    define_as = "BASE_GREATAXE",
    slot = "MAIN_HAND",
    slot_forbid = "OFF_HAND",
    type = "weapon", subtype="axe",
    image = "tiles/greataxe.png",
    display = "\\", color=colors.SLATE,
    moddable_tile = resolvers.moddable_tile("greataxe"),
    encumber = 12,
    rarity = 10,
    martial = true,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A great metal axe.\n\n Damage 1d12. Critical x3.",
    name = "greataxe",
    level_range = {1, 10},
    cost = 20,
    combat = {
        dam = {1,12},
        critical = 3,
    },
}


newEntity{ base = "BASE_WEAPON_TWOHANDED",
    define_as = "BASE_GREATCLUB",
    slot = "MAIN_HAND",
    slot_forbid = "OFF_HAND",
    type = "weapon", subtype="club",
    image = "tiles/club.png",
    display = "\\", color=colors.SLATE,
    encumber = 8,
    rarity = 5,
    martial = true,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A huge wooden club.\n\n Damage 1d10.",
    name = "greatclub",
    level_range = {1, 10},
    cost = 5,
    combat = {
        dam = {1,10},
    },
}

newEntity{ base = "BASE_WEAPON_TWOHANDED",
    define_as = "BASE_HEAVYFLAIL",
    slot = "MAIN_HAND",
    slot_forbid = "OFF_HAND",
    type = "weapon", subtype="flail",
    image = "tiles/flail.png",
    display = "/", color=colors.SLATE,
    encumber = 10,
    rarity = 10,
    martial = true,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A heavy flail.\n\n Damage 1d10. Threat range 19-20.",
    name = "heavy flail",
    level_range = {1, 10},
    cost = 15,
    combat = {
        dam = {1,10},
        threat = 1,
    },
}

newEntity{ base = "BASE_WEAPON_TWOHANDED",
    define_as = "BASE_GREATSWORD",
    slot = "MAIN_HAND",
    slot_forbid = "OFF_HAND",
    type = "weapon", subtype="sword",
    image = "tiles/greatsword.png",
    display = "|", color=colors.SLATE,
    moddable_tile = resolvers.moddable_tile("greatsword"),
    encumber = 8,
    rarity = 10,
    martial = true,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A metal great two-handed sword.\n\n Damage 2d6. Threat range 19-20.",
    name = "greatsword",
    level_range = {1, 10},
    cost = 50,
    combat = {
        dam = {2,6},
        threat = 1,
    },
}

newEntity{ base = "BASE_WEAPON_TWOHANDED",
    define_as = "BASE_HALBERD",
    slot = "MAIN_HAND",
    slot_forbid = "OFF_HAND",
    type = "weapon", subtype="halberd",
    image = "tiles/halberd.png",
    display = "/", color=colors.SLATE,
    encumber = 12,
    rarity = 10,
    martial = true,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A metal halberd.\n\n Damage 1d10. Critical x3.",
    name = "halberd",
    level_range = {1, 10},
    cost = 10,
    combat = {
        dam = {1,10},
        critical = 3,
    },
}

newEntity{ base = "BASE_WEAPON_TWOHANDED",
    define_as = "BASE_SCYTHE",
    slot = "MAIN_HAND",
    slot_forbid = "OFF_HAND",
    type = "weapon", subtype="scythe",
    image = "tiles/scythe.png",
    display = "\\", color=colors.SLATE,
    encumber = 10,
    rarity = 12,
    martial = true,
    combat = { sound = "actions/melee", sound_miss = "actions/melee_miss", },
    desc = "A frightening-looking metal scythe.\n\n Damage 2d4. Critical x4.",
    name = "scythe",
    level_range = {1, 10},
    cost = 18,
    combat = {
        dam = {2,4},
        critical = 4,
    },
}