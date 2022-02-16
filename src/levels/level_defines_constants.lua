LEVEL_NONE = 0
LEVEL_UNKNOWN_1 = 1
LEVEL_UNKNOWN_2 = 2
LEVEL_UNKNOWN_3 = 3
LEVEL_BBH = 4
LEVEL_CCM = 5
LEVEL_CASTLE = 6
LEVEL_HMC = 7
LEVEL_SSL = 8
LEVEL_BOB = 9
LEVEL_SL = 10
LEVEL_WDW = 11
LEVEL_JRB = 12
LEVEL_THI = 13
LEVEL_TTC = 14
LEVEL_RR = 15
LEVEL_CASTLE_GROUNDS = 16
LEVEL_BITDW = 17
LEVEL_VCUTM = 18
LEVEL_BITFS = 19
LEVEL_SA = 20
LEVEL_BITS = 21
LEVEL_LLL = 22
LEVEL_DDD = 23
LEVEL_WF = 24
LEVEL_ENDING = 25
LEVEL_CASTLE_COURTYARD = 26
LEVEL_PSS = 27
LEVEL_COTMC = 28
LEVEL_TOTWC = 29
LEVEL_BOWSER_1 = 30
LEVEL_WMOTR = 31
LEVEL_UNKNOWN_32 = 32
LEVEL_BOWSER_2 = 33
LEVEL_BOWSER_3 = 34
LEVEL_UNKNOWN_35 = 35
LEVEL_TTM = 36
LEVEL_UNKNOWN_37 = 37
LEVEL_UNKNOWN_38 = 38

LEVEL_COUNT = 40
LEVEL_MIN = 1
LEVEL_MAX = 40

LEVEL_CCM_2 = 57

LEVEL_CASTLE_2 = 602
LEVEL_CASTLE_3 = 41

-- Define lists for list of level for macros. Each of the following fields are described:
-- Argument 1: Internal ROM name of the level.
-- Argument 2: Level enumerator for enum used to identify the level ID.
-- Argument 3: Course enumerator for enum used to identify the course ID.
-- Argument 4: Shorthand name of the level which should be the name of the levels/ folder of the level.
-- Argument 5: The shared texture bin used.
-- Argument 6: Acoustic reaches for each levels.
-- Argument 7, 8, 9: Echo levels for individual areas.
-- Argument 10: Specify dynamic music tables for levels, if specified. _ for none.
-- Argument 11: Specify level camera table, if specified. _ for none.

-- NOTE: Be sure to edit sZoomOutAreaMasks in camera.c, as there isnt a good way to macro those right now.
-- TODO: Figure something out for sZoomOutAreaMasks?

local function define_level(name, level, course, short, texture, reaches, echo1, echo2, echo3, music, camera)
	return {name=name, level=level, course=course, short=short, texture=texture, reaches=reaches, echo1=echo1, echo2=echo2, echo3=echo3, music=music, camera=camera}
end

level_defines = {
	define_level( nil,             LEVEL_UNKNOWN_1,        COURSE_NONE,      nil,                nil,       20000,    0x00, 0x00, 0x00,  nil,        nil),
	define_level( nil,             LEVEL_UNKNOWN_2,        COURSE_NONE,      nil,                nil,       20000,    0x00, 0x00, 0x00,  nil,        nil),
	define_level( nil,             LEVEL_UNKNOWN_3,        COURSE_NONE,      nil,                nil,       20000,    0x00, 0x00, 0x00,  nil,        nil),
	define_level("TERESA OBAKE",   LEVEL_BBH,              COURSE_BBH,      'bbh',              'spooky',   28000,    0x28, 0x28, 0x28, 'sDynBbh',  'sCamBBH'),
	define_level("YYAMA1 % YSLD1", LEVEL_CCM,              COURSE_CCM,      'ccm',              'snow',     17000,    0x10, 0x38, 0x38,  nil,       'sCamCCM'),
	define_level("SELECT ROOM",    LEVEL_CASTLE,           COURSE_NONE,     'castle_inside',    'inside',   20000,    0x20, 0x20, 0x30,  nil,       'sCamCastle'),
	define_level("HORROR DUNGEON", LEVEL_HMC,              COURSE_HMC,      'hmc',              'cave',     16000,    0x28, 0x28, 0x28, 'sDynHmc',  'sCamHMC'),
	define_level("SABAKU % PYRMD", LEVEL_SSL,              COURSE_SSL,      'ssl',              'generic',  15000,    0x08, 0x30, 0x30,  nil,       'sCamSSL'),
	define_level("BATTLE FIELD",   LEVEL_BOB,              COURSE_BOB,      'bob',              'generic',  15000,    0x08, 0x08, 0x08,  nil,        nil),
	define_level("YUKIYAMA2",      LEVEL_SL,               COURSE_SL,       'sl',               'snow',     14000,    0x10, 0x28, 0x28,  nil,       'sCamSL'),
	define_level("POOL KAI",       LEVEL_WDW,              COURSE_WDW,      'wdw',              'grass',    17000,    0x10, 0x18, 0x18, 'sDynWdw',   nil),
	define_level("WTDG % TINBOTU", LEVEL_JRB,              COURSE_JRB,      'jrb',              'water',    20000,    0x10, 0x18, 0x18, 'sDynJrb',   nil),
	define_level("BIG WORLD",      LEVEL_THI,              COURSE_THI,      'thi',              'grass',    20000,    0x0c, 0x0c, 0x20,  nil,       'sCamTHI'),
	define_level("CLOCK TOWER",    LEVEL_TTC,              COURSE_TTC,      'ttc',              'machine',  18000,    0x18, 0x18, 0x18,  nil,        nil),
	define_level("RAINBOW CRUISE", LEVEL_RR,               COURSE_RR,       'rr',               'sky',      20000,    0x20, 0x20, 0x20,  nil,       'sCamRR'),
	define_level("MAIN MAP",       LEVEL_CASTLE_GROUNDS,   COURSE_NONE,     'castle_grounds',   'outside',  25000,    0x08, 0x08, 0x08,  nil,        nil),
	define_level("EXT1 YOKO SCRL", LEVEL_BITDW,            COURSE_BITDW,    'bitdw',            'sky',      16000,    0x28, 0x28, 0x28,  nil,        nil),
	define_level("EXT7 HORI MINI", LEVEL_VCUTM,            COURSE_VCUTM,    'vcutm',            'outside',  30000,    0x28, 0x28, 0x28,  nil,        nil),
	define_level("EXT2 TIKA LAVA", LEVEL_BITFS,            COURSE_BITFS,    'bitfs',            'sky',      16000,    0x28, 0x28, 0x28,  nil,        nil),
	define_level("EXT9 SUISOU",    LEVEL_SA,               COURSE_SA,       'sa',               'inside',   20000,    0x10, 0x10, 0x10,  nil,        nil),
	define_level("EXT3 HEAVEN",    LEVEL_BITS,             COURSE_BITS,     'bits',             'sky',      16000,    0x28, 0x28, 0x28,  nil,        nil),
	define_level("FIREB1 % INVLC", LEVEL_LLL,              COURSE_LLL,      'lll',              'fire',     22000,    0x08, 0x30, 0x30,  nil,        nil),
	define_level("WATER LAND",     LEVEL_DDD,              COURSE_DDD,      'ddd',              'water',    17000,    0x10, 0x20, 0x20, 'sDynDdd',   nil),
	define_level("MOUNTAIN",       LEVEL_WF,               COURSE_WF,       'wf',               'grass',    13000,    0x08, 0x08, 0x08,  nil,        nil),
	define_level("ENDING",         LEVEL_ENDING,           COURSE_CAKE_END, 'ending',           'generic',  20000,    0x00, 0x00, 0x00,  nil,        nil),
	define_level("URANIWA",        LEVEL_CASTLE_COURTYARD, COURSE_NONE,     'castle_courtyard', 'outside',  20000,    0x08, 0x08, 0x08,  nil,        nil),
	define_level("EXT4 MINI SLID", LEVEL_PSS,              COURSE_PSS,      'pss',              'mountain', 20000,    0x28, 0x28, 0x28,  nil,        nil),
	define_level("IN THE FALL",    LEVEL_COTMC,            COURSE_COTMC,    'cotmc',            'cave',     18000,    0x28, 0x28, 0x28,  nil,       'sCamCotMC'),
	define_level("EXT6 MARIO FLY", LEVEL_TOTWC,            COURSE_TOTWC,    'totwc',            'sky',      20000,    0x20, 0x20, 0x20,  nil,        nil),
	define_level("KUPPA1",         LEVEL_BOWSER_1,         COURSE_BITDW,    'bowser_1',         'generic',  60000,    0x40, 0x40, 0x40,  nil,        nil),
	define_level("EXT8 BLUE SKY",  LEVEL_WMOTR,            COURSE_WMOTR,    'wmotr',            'generic',  20000,    0x28, 0x28, 0x28,  nil,        nil),
	define_level( nil,             LEVEL_UNKNOWN_32,       COURSE_NONE,      nil,                nil,       20000,    0x70, 0x00, 0x00,  nil,        nil),
	define_level("KUPPA2",         LEVEL_BOWSER_2,         COURSE_BITFS,    'bowser_2',         'fire',     60000,    0x40, 0x40, 0x40,  nil,        nil),
	define_level("KUPPA3",         LEVEL_BOWSER_3,         COURSE_BITS,     'bowser_3',         'generic',  60000,    0x40, 0x40, 0x40,  nil,        nil),
	define_level( nil,             LEVEL_UNKNOWN_35,       COURSE_NONE,      nil,                nil,       20000,    0x00, 0x00, 0x00,  nil,        nil),
	define_level("DONKEY % SLID2", LEVEL_TTM,              COURSE_TTM,      'ttm',              'mountain', 15000,    0x08, 0x08, 0x08,  nil,        nil),
	define_level( nil,             LEVEL_UNKNOWN_37,       COURSE_NONE,      nil,                nil,       20000,    0x00, 0x00, 0x00,  nil,        nil),
	define_level( nil,             LEVEL_UNKNOWN_38,       COURSE_NONE,      nil,                nil,       20000,    0x00, 0x00, 0x00, 'sDynUnk38', nil),
}
