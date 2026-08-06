Config = {}

Config.DevMode = true -- true or false
Config.Locale = 'en' -- en, de, fr
Config.MenuEnableCursor = false -- show the mouse cursor while the menu is open
Config.MenuItemsOnScreen = 8 -- menu entries visible before scrolling (max 13)


Config.TeleportBackOnStop = true -- teleport player back to starting position when stopping interaction
Config.DetectionInterval = 500 -- detection interval in ms while no interactable is nearby
Config.DetectionIntervalNear = 250 -- detection interval in ms while standing at an interactable

Config.Keys = { interact = `INPUT_INTERACT_OPTION1`, standUp = `INPUT_QUIT` } -- G, Back Space

-- Optional interaction effects
Config.Effects = {
    ['clean'] = function()
        local ped = PlayerPedId()
        ClearPedEnvDirt(ped)
        ClearPedDamageDecalByZone(ped, 10, 'ALL')
        ClearPedBloodDamage(ped)
    end
}

-- Areas where prompts/menus are disabled
Config.BannedAreas = {
    {
        coords = vector3(-306.482, 809.1139, 118.98),
        radius = 5,
    },
}

-- Interaction categories for menu organization
Config.CategoryOrder = { 'sitting', 'drinking_smoking', 'instruments', 'activities', 'resting', 'other' }

Config.Categories = {
    sitting = {
        labelKey = 'category_sitting',
        scenarios = {
            'GENERIC_SEAT_BENCH_SCENARIO',
            'GENERIC_SEAT_CHAIR_SCENARIO',
            'GENERIC_SEAT_CHAIR_TABLE_SCENARIO',
            'MP_LOBBY_PROP_HUMAN_SEAT_CHAIR',
            'PROP_HUMAN_SEAT_CHAIR',
            'PROP_HUMAN_SEAT_CHAIR_PORCH',
            'PROP_CAMP_FIRE_SEAT_CHAIR',
            'PROP_HUMAN_CAMP_FIRE_SEAT_BOX',
            'PROP_HUMAN_SEAT_CHAIR_FAN',
            'PROP_HUMAN_SEAT_CHAIR_GROOMING_GROSS',
            'PROP_HUMAN_SEAT_BENCH',
            'PROP_PLAYER_SEAT_CHAIR_GENERIC',
            'PROP_HUMAN_SEAT_BENCH_PORCH',
            'PROP_HUMAN_SEAT_CHAIR_SAD',
            'MP_LOBBY_SEATED_A',
            'MP_LOBBY_SEATED_B',
            'MP_LOBBY_SEATED_C',
            'MP_LOBBY_SEATED_D',
            'MP_LOBBY_SEATED_E',
            'MP_LOBBY_SEATED_F',
            'PROP_CAMP_FIRE_SEATED',
            'PROP_CAMP_FIRE_SEAT_BENCH',
            'PROP_HUMAN_SEAT_NO_BACK_COLLECTION',
            'PROP_PLAYER_BARBER_SEAT',
            'PROP_PLAYER_SEAT_CHAIR_DYNAMIC',
            'PROP_PLAYER_DYNAMIC_SEAT_CHAIR_TABLE',
        }
    },
    drinking_smoking = {
        labelKey = 'category_drinking_smoking',
        scenarios = {
            'MP_LOBBY_PROP_HUMAN_SEAT_BENCH_PORCH_DRINKING',
            'PROP_HUMAN_SEAT_CHAIR_TABLE_DRINKING',
            'PROP_HUMAN_SEAT_CHAIR_DRINKING',
            'PROP_HUMAN_SEAT_CHAIR_DRINKING_MOONSHINE',
            'PROP_HUMAN_SEAT_CHAIR_TABLE_DRINKING_WHISKEY_MOONSHINE',
            'MP_LOBBY_PROP_HUMAN_SEAT_BENCH_PORCH_SMOKING',
            'PROP_HUMAN_SEAT_CHAIR_LANGTON',
            'PROP_HUMAN_SEAT_CHAIR_CIGAR',
            'PROP_HUMAN_SEAT_CHAIR_SMOKE_ROLL',
            'PROP_HUMAN_SEAT_CHAIR_SMOKING',
            'PROP_HUMAN_SEAT_CHAIR_TABLE_DRINKING_MOONSHINE',
        }
    },
    instruments = {
        labelKey = 'category_instruments',
        scenarios = {
            'PROP_HUMAN_SEAT_CHAIR_BANJO',
            'PROP_HUMAN_SEAT_BENCH_CONCERTINA',
            'PROP_HUMAN_SEAT_CHAIR_GUITAR',
            'PROP_HUMAN_SEAT_BENCH_HARMONICA',
            'PROP_HUMAN_SEAT_BENCH_JAW_HARP',
            'PROP_HUMAN_SEAT_BENCH_MANDOLIN',
            'PROP_HUMAN_SEAT_BENCH_FIDDLE',
            'PROP_HUMAN_PIANO',
            'PROP_HUMAN_PIANO_UPPERCLASS',
            'PROP_HUMAN_PIANO_RIVERBOAT',
            'PROP_HUMAN_PIANO_SKETCHY',
            'PROP_HUMAN_ABIGAIL_PIANO',
            'MP_MOONSHINE_BAND_WORLD_HUMAN_PIANO',
            'PROP_HUMAN_SEAT_CHAIR_BLUES_GUITAR',
            'MP_MOONSHINE_BAND_PROP_HUMAN_SEAT_CHAIR_BANJO',
            'MP_MOONSHINE_BAND_PROP_HUMAN_SEAT_CHAIR_WASHBOARD',
        }
    },
    activities = {
        labelKey = 'category_activities',
        scenarios = {
            'MP_LOBBY_PROP_HUMAN_SEAT_CHAIR_WHITTLE',
            'PROP_HUMAN_SEAT_CHAIR_READING',
            'PROP_HUMAN_SEAT_CHAIR_KNITTING',
            'PROP_HUMAN_SEAT_CHAIR_GROOMING_POSH',
            'PROP_HUMAN_SEAT_CHAIR_KNIFE_BADASS',
            'MP_LOBBY_PROP_HUMAN_SEAT_CHAIR_KNIFE_BADASS',
            'WORLD_CAMP_JAVIER_KNIFE',
            'PROP_HUMAN_SEAT_CHAIR_FISHING_ROD',
            'PROP_HUMAN_SEAT_CHAIR_CRAB_TRAP',
            'PROP_HUMAN_SEAT_CHAIR_CLEAN_SADDLE',
            'PROP_HUMAN_SEAT_CRATE_CLEAN_BOOTS',
            'PROP_CAMP_JAVIER_SEAT_CRATE_BRUSH_HAT',
            'PROP_CAMP_CHARLES_SEAT_CHAIR_ARROW_FLETCH',
            'PROP_HUMAN_SEAT_CHAIR_MORTAR_PESTLE',
            'PROP_HUMAN_SEAT_CHAIR_CLEAN_RIFLE',
            'PROP_CAMP_MICAH_SEAT_CHAIR_CLEAN_GUN',
            'PROP_HUMAN_SEAT_CHAIR_SKETCHING',
            'PROP_HUMAN_SEAT_CHAIR_SEWING',
            'PROP_HUMAN_SEAT_CHAIR_TABLE_FAN_WHORE',
            'PROP_HUMAN_SEAT_CHAIR_WHITTLE',
            'PROP_HUMAN_SEAT_CHAIR_CARVE_LURE',
        }
    },
    resting = {
        labelKey = 'category_resting',
        scenarios = {
            'PROP_HUMAN_SEAT_BENCH_BACK',
            'PROP_HUMAN_SEAT_BENCH_TIRED',
            'PROP_HUMAN_PASSED_OUT_TABLE',
            'PROP_HUMAN_SLEEP_BED_PILLOW',
            'PROP_HUMAN_SLEEP_BED_PILLOW_HIGH',
            'WORLD_HUMAN_SLEEP_GROUND_ARM',
            'WORLD_HUMAN_SLEEP_GROUND_PILLOW',
            'WORLD_HUMAN_SIT_FALL_ASLEEP',
            'WORLD_PLAYER_SLEEP_BEDROLL',
            'WORLD_PLAYER_SLEEP_GROUND',
        }
    },
    other = {
        labelKey = 'category_other',
        scenarios = {}
    }
}

-- List of interactable objects
Config.Interactions = {
    -- Pianos
    {
        isCompatible = IsPedHuman,
        objects = {'p_piano03x'},
        radius = 2.0,
        scenarios = PianoScenarios,
        x = 0.0,
        y = -0.70,
        z = 0.5,
        heading = 0.0
    },
    {
        isCompatible = IsPedHuman,
        objects = {'p_piano02x'},
        radius = 2.0,
        scenarios = PianoScenarios,
        x = 0.0,
        y = -0.70,
        z = 0.5,
        heading = 0.0
    },
    {
        isCompatible = IsPedHuman,
        objects = {'p_nbxpiano01x'},
        radius = 2.0,
        scenarios = PianoScenarios,
        x = -0.1,
        y = -0.75,
        z = 0.5,
        heading = 0.0
    },
    {
        isCompatible = IsPedHuman,
        objects = {'p_nbmpiano01x'},
        radius = 2.0,
        scenarios = PianoScenarios,
        x = 0.0,
        y = -0.77,
        z = 0.5,
        heading = 0.0
    },
    {
        objects = {'sha_man_piano01'},
        radius = 2.0,
        scenarios = PianoScenarios,
        x = 0.0,
        y = -0.75,
        z = 0.5,
        heading = 0.0
    },
    {
        isCompatible = IsPedAdult,
        objects = GenericChairs,
        radius = 1.5,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.0,
        y = 0.0,
        z = 0.5,
        heading = 180.0
    },
    {
        isCompatible = IsPedAdult,
        objects = GenericChairs,
        radius = 1.5,
        scenarios = DrinkingScenarios,
        x = 0.0,
        y = 0.05,
        z = -0.1,
        heading = 180.0
    },
    {
        isCompatible = IsPedHumanMale,
        objects = GenericChairs,
        radius = 1.5,
        scenarios = WhiskeyScenarios,
        x = 0.0,
        y = 0.0,
        z = 0.5,
        heading = 155.0
    },
    {
        isCompatible = IsPedAdult,
        objects = GenericBenches,
        label = 'left',
        radius = 1.5,
        scenarios = DrinkingScenarios,
        x = 0.4,
        y = -0.05,
        z = -0.1,
        heading = 180.0
    },
    {
        isCompatible = IsPedAdult,
        objects = GenericBenches,
        label = 'right',
        radius = 1.5,
        scenarios = DrinkingScenarios,
        x = -0.4,
        y = -0.05,
        z = -0.1,
        heading = 180.0
    },
    {
        isCompatible = IsPedAdult,
        objects = {'p_chairrusticsav01x'},
        radius = 1.5,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.0,
        y = -0.1,
        z = 0.5,
        heading = 180.0
    },
    {
        isCompatible = IsPedHumanMale,
        objects = {'p_bench11x'},
        label = 'left',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.5,
        y = 0.0,
        z = 0.5,
        heading = 180.0
    },
    {
        isCompatible = IsPedHumanMale,
        objects = {'p_bench11x'},
        label = 'right',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = -0.5,
        y = 0.0,
        z = 0.5,
        heading = 180.0
    },
    {
        isCompatible = IsPedAdultFemale,
        objects = {'p_bench11x'},
        label = 'left',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.5,
        y = 0.0,
        z = 0.5,
        heading = 180.0
    },
    {
        isCompatible = IsPedAdultFemale,
        objects = {'p_bench11x'},
        label = 'right',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = -0.5,
        y = 0.0,
        z = 0.5,
        heading = 180.0
    },
    {
        isCompatible = IsPedAdult,
        objects = {'p_chairtall01x'},
        radius = 1.5,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.0,
        y = 0.0,
        z = 0.8,
        heading = 180.0
    },
    {
        isCompatible = IsPedHuman,
        objects = {'p_barstool01x'},
        radius = 1.5,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.0,
        y = 0.0,
        z = 0.8,
        heading = 0.0
    },
    {
        isCompatible = IsPedChild,
        objects = GenericChairs,
        radius = 1.5,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.0,
        y = 0.0,
        z = 0.4,
        heading = 180.0
    },
    {
        isCompatible = IsPedHumanFemale,
        objects = GenericBenches,
        label = 'right',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = -0.5,
        y = 0.0,
        z = 0.5,
        heading = 180.0
    },
    {
        isCompatible = IsPedHumanFemale,
        objects = GenericBenches,
        label = 'left',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.5,
        y = 0.0,
        z = 0.5,
        heading = 180.0
    },
    {
        isCompatible = IsPedHumanMale,
        objects = GenericBenches,
        label = 'right',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = -0.5,
        y = 0.0,
        z = 0.5,
        heading = 180.0
    },
    {
        isCompatible = IsPedHumanMale,
        objects = GenericBenches,
        label = 'left',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.5,
        y = 0.0,
        z = 0.5,
        heading = 180.0
    },
    {
        objects = {'p_benchlong05x'},
        label = 'left',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = 1.2,
        y = 0.0,
        z = 0.5,
        heading = 180.0
    },
    {
        objects = {'p_benchlong05x'},
        label = 'right',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = -0.6,
        y = 0.0,
        z = 0.5,
        heading = 180.0
    },
    {
        objects = {'p_benchlong05x'},
        label = 'middle',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.3,
        y = 0.0,
        z = 0.5,
        heading = 180.0
    },
    {
        objects = {'p_chairconvoround01x'},
        label = 'left',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = -0.7,
        y = -0.7,
        z = 0.45,
        heading = 132
    },
    {
        objects = {'p_chairconvoround01x'},
        label = 'right',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.7,
        y = -0.6,
        z = 0.45,
        heading = 225
    },
    {
        isCompatible = IsPedHumanMale,
        objects = {
            'p_bench17x',
            'p_benchbear01x'
        },
        label = 'right',
        radius = 1.5,
        scenarios = GenericChairAndBenchScenarios,
        x = -0.3,
        y = 0.0,
        z = 0.5,
        heading = 180.0
    },
    {
        objects = {
            'p_bench17x',
            'p_benchbear01x'
        },
        label = 'left',
        radius = 1.5,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.3,
        y = 0.0,
        z = 0.5,
        heading = 180.0
    },
    {
        objects = {
            'p_bed14x',
            'p_bed17x',
            'p_bed21x',
            'p_bedbunk03x',
            'p_bedindian02x',
            'p_cot01x'
        },
        radius = 2.0,
        scenarios = BedScenarios,
        x = 0.0,
        y = 0.0,
        z = 0.5,
        heading = 180.0
    },
    {
        objects = {'p_bedbunk03x'},
        label = 'up',
        radius = 2.0,
        scenarios = BedScenarios,
        x = 0.0,
        y = 0.0,
        z = 1.68,
        heading = 180.0
    },
    {
        objects = {
            'p_bed20madex',
            'p_cs_pro_bed_unmade',
            'p_cs_bed20madex'
        },
        label = 'right',
        radius = 2.0,
        scenarios = BedScenarios,
        x = -0.3,
        y = -0.2,
        z = 0.5,
        heading = 180.0
    },
    {
        objects = {
            'p_bed20madex',
            'p_cs_pro_bed_unmade',
            'p_cs_bed20madex'
        },
        label = 'left',
        radius = 2.0,
        scenarios = BedScenarios,
        x = 0.3,
        y = -0.2,
        z = 0.5,
        heading = 180.0
    },
    {
        objects = {
            'p_ambbed01x',
            'p_bed03x',
            'p_bed09x',
            'p_bedindian01x'
        },
        radius = 2.0,
        scenarios = BedScenarios,
        x = 0.0,
        y = 0.0,
        z = 0.5,
        heading = 270.0
    },
    {
        objects = {
            'p_bed05x'
        },
        radius = 2.0,
        scenarios = BedScenarios,
        x = 0.0,
        y = -0.5,
        z = 0.5,
        heading = 180.0
    },
    {
        objects = {
            'p_bed10x',
            'p_bed12x',
            'p_bed13x',
            'p_bed22x'
        },
        radius = 2.0,
        scenarios = BedScenarios,
        x = 0.0,
        y = -0.3,
        z = 0.8,
        heading = 180.0
    },
    {
        objects = {
            'p_bed20x'
        },
        label = 'right',
        radius = 2.0,
        scenarios = BedScenarios,
        x = -0.3,
        y = -0.2,
        z = 0.8,
        heading = 180.0
    },
    {
        objects = {
            'p_bed20x'
        },
        label = 'left',
        radius = 2.0,
        scenarios = BedScenarios,
        x = 0.3,
        y = -0.2,
        z = 0.8,
        heading = 180.0
    },
    {
        objects = {
            'p_bedking02x'
        },
        label = 'left',
        radius = 2.0,
        scenarios = BedScenarios,
        x = -0.5,
        y = 0.5,
        z = 0.5,
        heading = 180.0
    },
    {
        objects = {
            'p_bedking02x'
        },
        label = 'right',
        radius = 2.0,
        scenarios = BedScenarios,
        x = 0.5,
        y = 0.5,
        z = 0.5,
        heading = 180.0
    },
    {
        objects = {
            'p_bedrollopen01x',
            'p_bedrollopen03x',
            'p_re_bedrollopen01x',
            's_bedrollfurlined01x',
            's_bedrollopen01x',
            'p_amb_mattress04x',
            'p_mattress04x',
            'p_mattress07x',
            'p_mattresscombined01x'
        },
        radius = 1.5,
        scenarios = BedScenarios,
        x = 0.0,
        y = 0.0,
        z = 0.0,
        heading = 180.0
    },
    {
        objects = {
            'p_cs_ann_wrkr_bed01x',
            'p_cs_roc_hse_bed',
            'p_medbed01x'
        },
        radius = 2.0,
        scenarios = BedScenarios,
        x = 0.1,
        y = 0.0,
        z = 0.85,
        heading = 270.0
    },
    {
        objects = {
            'p_cs_bedsleptinbed08x'
        },
        label = 'left',
        radius = 2.0,
        scenarios = BedScenarios,
        x = 0.3,
        y = -0.3,
        z = 0.5,
        heading = 270.0
    },
    {
        objects = {
            'p_cs_bedsleptinbed08x'
        },
        label = 'right',
        radius = 2.0,
        scenarios = BedScenarios,
        x = 0.3,
        y = 0.3,
        z = 0.5,
        heading = 270.0
    },

    -- Custom objects
    -- St. Denis Church Chair
    {
        isCompatible = IsPedAdult,
        objects = {'sdchurchchair'},
        radius = 1.5,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.0,
        y = -0.1,
        z = -0.1,
        heading = 180.0
    },
    -- St. Denis Church Bench
    {
        isCompatible = IsPedHumanMale,
        objects = {'sdchurchbench'},
        label = 'left',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.5,
        y = -0.3,
        z = -0.375,
        heading = 180.0
    },
    {
        isCompatible = IsPedHumanMale,
        objects = {'sdchurchbench'},
        label = 'right',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = -0.5,
        y = -0.3,
        z = -0.375,
        heading = 180.0
    },
    {
        isCompatible = IsPedAdultFemale,
        objects = {'sdchurchbench'},
        label = 'left',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.5,
        y = -0.3,
        z = -0.375,
        heading = 180.0
    },
    {
        isCompatible = IsPedAdultFemale,
        objects = {'sdchurchbench'},
        label = 'right',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = -0.5,
        y = -0.3,
        z = -0.375,
        heading = 180.0
    },
    -- St. Denis Church Organ
    {
        isCompatible = IsPedHuman,
        objects = {'pipeorgan'},
        radius = 2.0,
        scenarios = PianoScenarios,
        x = 0.0,
        y = -0.70,
        z = -0.65,
        heading = 0.0
    },
    {
        isCompatible = IsPedHumanFemale,
        objects = {'pipeorgan'},
        radius = 2.0,
        scenarios = PianoScenarios,
        x = 0.0,
        y = -0.70,
        z = -0.625,
        heading = 0.0
    },
    -- Shoe stand
    {
        isCompatible = IsPedHumanFemale,
        objects = {'p_shoeshinestand01x'},
        label = 'right',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = -0.45,
        y = 0.25,
        z = 1.2,
        heading = 180.0
    },
    {
        isCompatible = IsPedHumanFemale,
        objects = {'p_shoeshinestand01x'},
        label = 'left',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.45,
        y = 0.25,
        z = 1.2,
        heading = 180.0
    },
    {
        isCompatible = IsPedHumanMale,
        objects = {'p_shoeshinestand01x'},
        label = 'right',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = -0.45,
        y = 0.25,
        z = 1.2,
        heading = 180.0
    },
    {
        isCompatible = IsPedHumanMale,
        objects = {'p_shoeshinestand01x'},
        label = 'left',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.45,
        y = 0.25,
        z = 1.2,
        heading = 180.0
    },
    -- Valentine Church Bench
    {
        isCompatible = IsPedHumanMale,
        objects = {'churchbench1'},
        label = 'left',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = -1.5,
        y = 0.0,
        z = -0.3,
        heading = 180.0
    },
    {
        isCompatible = IsPedHumanMale,
        objects = {'churchbench1'},
        label = 'right',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.0,
        y = 0.0,
        z = -0.3,
        heading = 180.0
    },
    {
        isCompatible = IsPedAdultFemale,
        objects = {'churchbench1'},
        label = 'left',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = -1.5,
        y = 0.0,
        z = -0.3,
        heading = 180.0
    },
    {
        isCompatible = IsPedAdultFemale,
        objects = {'churchbench1'},
        label = 'right',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.0,
        y = 0.0,
        z = -0.3,
        heading = 180.0
    },
    {
        isCompatible = IsPedHumanMale,
        objects = {'churchbench2'},
        label = 'left',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.0,
        y = 0.0,
        z = -0.3,
        heading = 180.0
    },
    {
        isCompatible = IsPedHumanMale,
        objects = {'churchbench2'},
        label = 'right',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = 1.5,
        y = 0.0,
        z = -0.3,
        heading = 180.0
    },
    {
        isCompatible = IsPedAdultFemale,
        objects = {'churchbench2'},
        label = 'left',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = 0.0,
        y = 0.0,
        z = -0.3,
        heading = 180.0
    },
    {
        isCompatible = IsPedAdultFemale,
        objects = {'churchbench2'},
        label = 'right',
        radius = 2.0,
        scenarios = GenericChairAndBenchScenarios,
        x = 1.5,
        y = 0.0,
        z = -0.3,
        heading = 180.0
    },
    -- Pole Prop
    {
        objects = {'pole'},
        radius = 1.5,
        animations = DancingAnimations,
        x = 0.0,
        y = 0.5,
        z = 1.0,
        heading = 180.0,
    },

    ---- Bath
    -- Valentine bath
    {
        radius = 2.0,
        animations = BathingAnimations,
        x = -317.01651,
        y = 761.86,
        z = 117.45099,
        heading = 100.278,
        effect = 'clean'
    },
    -- Saint Denis bath
    {
        radius = 2.0,
        animations = BathingAnimations,
        x = 2629.4099,
        y = -1223.7757,
        z = 59.6699,
        heading = 2.896,
        effect = 'clean'
    },
    -- Strawberry bath
    {
        radius = 2.0,
        animations = BathingAnimations,
        x = -1812.46838,
        y = -373.23529,
        z = 166.64999,
        heading = 92.105,
        effect = 'clean'
    },
    -- Annesburg bath
    {
        radius = 2.0,
        animations = BathingAnimations,
        x = 2952.804199,
        y = 1335.031494,
        z = 44.496986,
        heading = 154.996,
        effect = 'clean'
    },
    -- Bronte Mansion bath
    {
        radius = 2.0,
        animations = BathingAnimations,
        x = 2365.649,
        y = -1211.780,
        z = 51.888,
        heading = 3.0,
        effect = 'clean'
    },
    -- Rhodes bath
    {
        radius = 2.0,
        animations = BathingAnimations,
        x = 1336.350,
        y = -1377.972,
        z = 84.345,
        heading = -96.693,
        effect = 'clean'
    },
    -- Tumbleweed bath
    {
        radius = 2.0,
        animations = BathingAnimations,
        x = -5513.196,
        y = -2972.139,
        z = -0.75,
        heading = 108.131,
        effect = 'clean'
    },
    -- Van Horn bath
    {
        radius = 2.0,
        animations = BathingAnimations,
        x = 2987.698,
        y = 573.760,
        z = 47.920,
        heading = 171.942,
        effect = 'clean'
    },
    -- Blackwater bath
    {
        radius = 2.0,
        animations = BathingAnimations,
        x = -823.362,
        y = -1318.832,
        z = 43.679,
        heading = 92.793,
        effect = 'clean'
    },
    {
        isCompatible = IsPedHumanMale,
        objects = {'p_bath03x'},
        radius = 2.0,
        animations = BathingAnimations,
        x = -0.5,
        y = 0.0,
        z = 0.65,
        heading = 270.0,
        effect = 'clean'
    },
    {
        isCompatible = IsPedHumanMale,
        objects = {'p_bath02x'},
        radius = 1.5,
        animations = BathingAnimations,
        x = 0.0,
        y = 0.5,
        z = 1.0,
        heading = 180.0,
        effect = 'clean'
    },
}
