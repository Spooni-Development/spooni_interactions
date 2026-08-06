-- Ped compatibility functions
function IsPedChild(ped)
    return Citizen.InvokeNative(0x137772000DAF42C5, ped)
end

function IsPedAdult(ped)
    return IsPedHuman(ped) and not IsPedChild(ped)
end

function IsPedHumanMale(ped)
    return IsPedHuman(ped) and IsPedMale(ped)
end

function IsPedHumanFemale(ped)
    return IsPedHuman(ped) and not IsPedMale(ped)
end

function IsPedAdultMale(ped)
    return not IsPedChild(ped) and IsPedMale(ped)
end

function IsPedAdultFemale(ped)
    return not IsPedChild(ped) and not IsPedMale(ped)
end

-- Generic object lists
GenericChairs = {
    'mp005_s_posse_col_chair01x',
    'mp005_s_posse_foldingchair_01x',
    'mp005_s_posse_trad_chair01x',
    'mp007_p_mp_chairdesk01x',
    'mp007_p_nat_chairfolding02x',
    's_stoolfoldingstatic01x',
    'p_ambchair01x',
    'p_ambchair02x',
    'p_armchair01x',
    'p_bistrochair01x',
    'p_chair02x',
    'p_chair04x',
    'p_chair05x',
    'p_chair06x',
    'p_chair07x',
    'p_chair09x',
    'p_chair_10x',
    'p_chair11x',
    'p_chair12bx',
    'p_chair12x',
    'p_chair13x',
    'p_chair14x',
    'p_chair15x',
    'p_chair16x',
    'p_chair17x',
    'p_chair18x',
    'p_chair19x',
    'p_chair20x',
    'p_chair21x',
    'p_chair21x_fussar',
    'p_chair22x',
    'p_chair23x',
    'p_chair24x',
    'p_chair25x',
    'p_chair26x',
    'p_chair27x',
    'p_chair30x',
    'p_chair31x',
    'p_chair37x',
    'p_chair38x',
    'p_chair_barrel04b',
    'p_chair_crate02x',
    'p_chair_crate15x',
    'p_chair_cs05x',
    'p_chairdesk01x',
    'p_chairdesk02x',
    'p_chairdining01x',
    'p_chairdining02x',
    'p_chairdining03x',
    'p_chaireagle01x',
    'p_chairfolding02x',
    'p_chairhob01x',
    'p_chairhob02x',
    'p_chairmed01x',
    'p_chairmed02x',
    'p_chairoffice02x',
    'p_chairpokerfancy01x',
    'p_chairporch01x',
    'p_chair_privatedining01x',
    'p_chairrocking02x',
    'p_chairrocking03x',
    'p_chairrocking04x',
    'p_chairrocking05x',
    'p_chairrocking06x',
    'p_chairrustic01x',
    'p_chairrustic02x',
    'p_chairrustic03x',
    'p_chairrustic04x',
    'p_chairrustic05x',
    'p_chairsalon01x',
    'p_chairvictorian01x',
    'p_chairwhite01x',
    'p_chairwicker01x',
    'p_chairwicker02x',
    'p_chaircomfy01x',
    'p_chaircomfy02',
    'p_chaircomfy03x',
    'p_chaircomfy04x',
    'p_chaircomfy05x',
    'p_chaircomfy06x',
    'p_chaircomfy07x',
    'p_chaircomfy08x',
    'p_chaircomfy09x',
    'p_chaircomfy10x',
    'p_chaircomfy11x',
    'p_chaircomfy12x',
    'p_chaircomfy14x',
    'p_chaircomfy17x',
    'p_chaircomfy18x',
    'p_chaircomfy22x',
    'p_chaircomfy23x',
    'p_chairdoctor01x',
    'p_cs_electricchair01x',
    'p_diningchairs01x',
    'p_gen_chair07x',
    'p_oldarmchair01x',
    'p_benchpiano02x',
    'p_pianochair01x',
    'p_privatelounge_chair01x',
    'p_rockingchair01x',
    'p_rockingchair02x',
    'p_rockingchair03x',
    'p_settee01x',
    'p_settee02bx',
    'p_settee03x',
    'p_settee03bx',
    'p_settee04x',
    'p_sit_chairwicker01b',
    'p_stool01x',
    'p_stool02x',
    'p_stool03x',
    'p_stool04x',
    'p_stool05x',
    'p_stool06x',
    'p_stool07x',
    'p_stool08x',
    'p_stool09x',
    'p_stool10x',
    'p_stool12x',
    'p_stool13x',
    'p_stool14x',
    'p_stoolcomfy01x',
    'p_stoolcomfy02x',
    'p_stoolfolding01bx',
    'p_stoolfolding01x',
    'p_stoolwinter01x',
    'p_theaterchair01b01x',
    'p_windsorchair01x',
    'p_windsorchair02x',
    'p_windsorchair03x',
    'p_woodenchair01x',
    'p_woodendeskchair01x',
}

GenericBenches = {
    'p_benchannsaloon01x',
    'p_victoriansofa01x',
    'p_bench03x',
    'p_bench06x',
    'p_bench08bx',
    'p_bench09x',
    'p_bench15_mjr',
    'p_bench15x',
    'p_bench16x',
    'p_bench18x',
    'p_bench20x',
    'p_benchch01x',
    'p_benchironnbx01x',
    'p_benchironnbx02x',
    'p_bench_log01x',
    'p_bench_log02x',
    'p_bench_log03x',
    'p_bench_log04x',
    'p_bench_log05x',
    'p_bench_log06x',
    'p_bench_log07x',
    'p_bench_logsnow07x',
    'p_benchnbx02x',
    'p_benchnbx03x',
    'p_couch01x',
    'p_couch02x',
    'p_couch05x',
    'p_couch06x',
    'p_couch08x',
    'p_couch09x',
    'p_couch10x',
    'p_couch11x',
    'p_couchwicker01x',
    'p_hallbench01x',
    'p_loveseat01x',
    'p_seatbench01x',
    'p_settee02x',
    'p_settee_05x',
    'p_sit_chairwicker01a',
    'p_sofa01x',
    'p_sofa02x',
    'p_windsorbench01x',
    'p_woodbench02x',
    's_bench01x',
}

-- Scenario Definitions
GenericChairAndBenchScenarios = {
    {
        name = 'GENERIC_SEAT_BENCH_SCENARIO',
        label = L('generic_seat_bench_scenario')
    },
    {
        name = 'GENERIC_SEAT_CHAIR_SCENARIO',
        isCompatible = IsPedHumanMale,
        label = L('generic_seat_chair_scenario')
    },
    {
        name = 'GENERIC_SEAT_CHAIR_TABLE_SCENARIO',
        label = L('generic_seat_chair_table_scenario')
    },
    {
        name = 'MP_LOBBY_PROP_HUMAN_SEAT_BENCH_PORCH_DRINKING',
        label = L('mp_lobby_prop_human_seat_bench_porch_drinking')
    },
    {
        name = 'MP_LOBBY_PROP_HUMAN_SEAT_BENCH_PORCH_SMOKING',
        label = L('mp_lobby_prop_human_seat_bench_porch_smoking')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_LANGTON',
        isCompatible = IsPedHumanMale,
        label = L('PROP_HUMAN_SEAT_CHAIR_LANGTON')
    },
    {
        name = 'MP_LOBBY_PROP_HUMAN_SEAT_CHAIR',
        label = L('mp_lobby_prop_human_seat_chair')
    },
    {
        name = 'MP_LOBBY_PROP_HUMAN_SEAT_CHAIR_WHITTLE',
        label = L('mp_lobby_prop_human_seat_chair_whittle')
    },
    {
        name = 'PROP_CAMP_FIRE_SEAT_CHAIR',
        label = L('prop_camp_fire_seat_chair')
    },
    {
        name = 'PROP_HUMAN_CAMP_FIRE_SEAT_BOX',
        label = L('prop_human_camp_fire_seat_box')
    },
    {
        name = 'PROP_HUMAN_SEAT_BENCH_CONCERTINA',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_seat_bench_concertina')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_FAN',
        isCompatible = IsPedHumanFemale,
        label = L('prop_human_seat_chair_fan')
    },
    {
        name = 'PROP_HUMAN_SEAT_BENCH_JAW_HARP',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_seat_bench_jaw_harp')
    },
    {
        name = 'PROP_HUMAN_SEAT_BENCH_MANDOLIN',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_seat_bench_mandolin')
    },
    {
        name = 'PROP_HUMAN_SEAT_BENCH_FIDDLE',
        isCompatible = IsPedHumanFemale,
        label = L('prop_human_seat_bench_fiddle')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR',
        label = L('prop_human_seat_chair')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_BANJO',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_seat_chair_banjo')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_CIGAR',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_seat_chair_cigar')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_GROOMING_GROSS',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_seat_chair_grooming_gross')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_GROOMING_POSH',
        isCompatible = IsPedHumanFemale,
        label = L('prop_human_seat_chair_grooming_posh')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_GUITAR',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_seat_chair_guitar')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_KNIFE_BADASS',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_seat_chair_knife_badass')
    },
    {
        name = 'MP_LOBBY_PROP_HUMAN_SEAT_CHAIR_KNIFE_BADASS',
        label = L('mp_lobby_prop_human_seat_chair_knife_badass')
    },
    {
        name = 'WORLD_CAMP_JAVIER_KNIFE',
        isCompatible = IsPedHumanMale,
        label = L('world_camp_javier_knife')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_KNITTING',
        isCompatible = IsPedHumanFemale,
        label = L('prop_human_seat_chair_knitting')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_PORCH',
        label = L('prop_human_seat_chair_porch')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_READING',
        label = L('prop_human_seat_chair_reading')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_TABLE_DRINKING',
        label = L('prop_human_seat_chair_table_drinking')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_DRINKING_MOONSHINE',
        label = L('prop_human_seat_chair_drinking_moonshine')
    },
    {
        name = 'PROP_HUMAN_SEAT_BENCH_HARMONICA',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_seat_bench_harmonica')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_SMOKE_ROLL',
        label = L('prop_human_seat_chair_smoke_roll')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_FISHING_ROD',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_seat_chair_fishing_rod')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_CRAB_TRAP',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_seat_chair_crab_trap')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_CLEAN_SADDLE',
        label = L('prop_human_seat_chair_clean_saddle')
    },
    {
        name = 'PROP_HUMAN_SEAT_CRATE_CLEAN_BOOTS',
        label = L('prop_human_seat_crate_clean_boots')
    },
    {
        name = 'PROP_CAMP_JAVIER_SEAT_CRATE_BRUSH_HAT',
        isCompatible = IsPedHumanMale,
        label = L('prop_camp_javier_seat_crate_brush_hat')
    },
    {
        name = 'PROP_CAMP_CHARLES_SEAT_CHAIR_ARROW_FLETCH',
        isCompatible = IsPedHumanMale,
        label = L('prop_camp_charles_seat_chair_arrow_fletch')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_MORTAR_PESTLE',
        label = L('prop_human_seat_chair_mortar_pestle')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_CLEAN_RIFLE',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_seat_chair_clean_rifle')
    },
    {
        name = 'PROP_CAMP_MICAH_SEAT_CHAIR_CLEAN_GUN',
        isCompatible = IsPedHumanMale,
        label = L('prop_camp_micah_seat_chair_clean_gun')
    },
    {
        name = 'PROP_HUMAN_SEAT_BENCH_BACK',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_seat_bench_back')
    },
    {
        name = 'PROP_HUMAN_SEAT_BENCH_TIRED',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_seat_bench_tired')
    },
    {
        name = 'PROP_HUMAN_PASSED_OUT_TABLE',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_passed_out_table')
    },
    {
        name = 'MP_LOBBY_SEATED_A',
        label = L('mp_lobby_seated_a')
    },
    {
        name = 'MP_LOBBY_SEATED_B',
        label = L('mp_lobby_seated_b')
    },
    {
        name = 'MP_LOBBY_SEATED_C',
        label = L('mp_lobby_seated_c')
    },
    {
        name = 'MP_LOBBY_SEATED_D',
        label = L('mp_lobby_seated_d')
    },
    {
        name = 'MP_LOBBY_SEATED_E',
        label = L('mp_lobby_seated_e')
    },
    {
        name = 'MP_LOBBY_SEATED_F',
        label = L('mp_lobby_seated_f')
    },
    {
        name = 'PROP_CAMP_FIRE_SEATED',
        label = L('prop_camp_fire_seated')
    },
    {
        name = 'PROP_CAMP_FIRE_SEAT_BENCH',
        label = L('prop_camp_fire_seat_bench')
    },
    {
        name = 'PROP_HUMAN_SEAT_NO_BACK_COLLECTION',
        label = L('prop_human_seat_no_back_collection')
    },
    {
        name = 'PROP_PLAYER_BARBER_SEAT',
        label = L('prop_player_barber_seat')
    },
    {
        name = 'MP_MOONSHINE_BAND_PROP_HUMAN_SEAT_CHAIR_BANJO',
        isCompatible = IsPedHumanMale,
        label = L('mp_moonshine_band_banjo')
    },
    {
        name = 'MP_MOONSHINE_BAND_PROP_HUMAN_SEAT_CHAIR_WASHBOARD',
        isCompatible = IsPedHumanMale,
        label = L('mp_moonshine_band_washboard')
    },
    {
        name = 'PROP_PLAYER_SEAT_CHAIR_DYNAMIC',
        isCompatible = IsPedHumanFemale,
        label = L('prop_player_seat_chair_dynamic')
    },
    {
        name = 'PROP_PLAYER_DYNAMIC_SEAT_CHAIR_TABLE',
        isCompatible = IsPedHumanFemale,
        label = L('prop_player_dynamic_seat_chair_table')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_SMOKING',
        label = L('prop_human_seat_chair_smoking')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_SKETCHING',
        label = L('prop_human_seat_chair_sketching')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_TABLE_DRINKING_MOONSHINE',
        label = L('prop_human_seat_chair_table_drinking_moonshine')
    },
    {
        name = 'PROP_HUMAN_SEAT_BENCH',
        label = L('prop_human_seat_bench')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_SAD',
        isCompatible = IsPedHumanFemale,
        label = L('prop_human_seat_chair_sad')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_SEWING',
        isCompatible = IsPedHumanFemale,
        label = L('prop_human_seat_chair_sewing')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_TABLE_FAN_WHORE',
        isCompatible = IsPedHumanFemale,
        label = L('prop_human_seat_chair_table_fan')
    },
    {
        name = 'PROP_PLAYER_SEAT_CHAIR_GENERIC',
        label = L('prop_player_seat_chair_generic')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_WHITTLE',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_seat_chair_whittle')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_BLUES_GUITAR',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_seat_chair_blues_guitar')
    },
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_CARVE_LURE',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_seat_chair_carve_lure')
    },
    {
        name = 'PROP_HUMAN_SEAT_BENCH_PORCH',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_seat_bench_porch')
    },
}

BedScenarios = {
    {
        name = 'PROP_HUMAN_SLEEP_BED_PILLOW',
        label = L('prop_human_sleep_bed_pillow')
    },
    {
        name = 'PROP_HUMAN_SLEEP_BED_PILLOW_HIGH',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_sleep_bed_pillow_high')
    },
    {
        name = 'WORLD_HUMAN_SLEEP_GROUND_ARM',
        label = L('world_human_sleep_ground_arm')
    },
    {
        name = 'WORLD_HUMAN_SLEEP_GROUND_PILLOW',
        label = L('world_human_sleep_ground_pillow')
    },
    {
        name = 'WORLD_HUMAN_SIT_FALL_ASLEEP',
        label = L('world_human_sit_fall_asleep')
    },
    {
        name = 'WORLD_PLAYER_SLEEP_BEDROLL',
        label = L('world_player_sleep_bedroll')
    },
    {
        name = 'WORLD_PLAYER_SLEEP_GROUND',
        label = L('world_player_sleep_ground')
    }
}

PianoScenarios = {
    {
        name = 'PROP_HUMAN_PIANO',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_piano')
    },
    {
        name = 'PROP_HUMAN_PIANO_UPPERCLASS',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_piano_upperclass')
    },
    {
        name = 'PROP_HUMAN_PIANO_RIVERBOAT',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_piano_riverboat')
    },
    {
        name = 'PROP_HUMAN_PIANO_SKETCHY',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_piano_sketchy')
    },
    {
        name = 'PROP_HUMAN_ABIGAIL_PIANO',
        isCompatible = IsPedHumanFemale,
        label = L('prop_human_abigail_piano')
    },
    {
        name = 'MP_MOONSHINE_BAND_WORLD_HUMAN_PIANO',
        label = L('mp_moonshine_band_world_human_piano')
    }
}

DrinkingScenarios = {
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_DRINKING',
        label = L('prop_human_seat_chair_drinking')
    }
}

WhiskeyScenarios = {
    {
        name = 'PROP_HUMAN_SEAT_CHAIR_TABLE_DRINKING_WHISKEY_MOONSHINE',
        isCompatible = IsPedHumanMale,
        label = L('prop_human_seat_chair_table_drinking_whiskey_moonshine')
    }
}

-- Animation Definitions
BathingAnimations = {
    {
        label = L('bath'),
        dict = 'mini_games@bathing@regular@arthur',
        name = 'bathing_idle_02'
    },
    {
        label = L('bath_scrub_left_arm'),
        dict = 'mini_games@bathing@regular@arthur',
        name = 'left_arm_scrub_medium'
    },
    {
        label = L('bath_scrub_right_arm'),
        dict = 'mini_games@bathing@regular@arthur',
        name = 'right_arm_scrub_medium'
    },
    {
        label = L('bath_scrub_left_leg'),
        dict = 'mini_games@bathing@regular@arthur',
        name = 'left_leg_scrub_medium'
    },
    {
        label = L('bath_scrub_right_leg'),
        dict = 'mini_games@bathing@regular@arthur',
        name = 'right_leg_scrub_medium'
    }
}

DancingAnimations = {
    {
        label = L('sword'),
        dict = 'script_shows@sworddance@act3_p1',
        name = 'dancer_sworddance'
    },
    {
        label = L('cancan'),
        dict = 'script_shows@cancandance@p2',
        name = 'cancandance_p2_fem1'
    },
    {
        label = L('fire'),
        dict = 'script_shows@firebreather@act2_p1',
        name = 'dancer_dance'
    },
    {
        label = L('snake'),
        dict = 'script_shows@snakedancer@act1_p1',
        name = 'dance_dancer'
    },
}


