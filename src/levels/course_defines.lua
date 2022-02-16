-- courses
COURSE_NONE = 0 -- Course Hub (Castle Grounds)
COURSE_BOB = 1 -- Bob Omb Battlefield
COURSE_WF = 2 -- Whomp's Fortress
COURSE_JRB = 3 -- Jolly Rodger's Bay
COURSE_CCM = 4 -- Cool Cool Mountain
COURSE_BBH = 5 -- Big Boo's Haunt
COURSE_HMC = 6 -- Hazy Maze Cave
COURSE_LLL = 7 -- Lethal Lava Land
COURSE_SSL = 8 -- Shifting Sand Land
COURSE_DDD = 9 -- Dire Dire Docks
COURSE_SL = 10 -- Snowman's Land
COURSE_WDW = 11 -- Wet Dry World
COURSE_TTM = 12 -- Tall Tall Mountain
COURSE_THI = 13 -- Tiny Huge Island
COURSE_TTC = 14 -- Tick Tock Clock
COURSE_RR = 15 -- Rainbow Ride

-- bonus courses
COURSE_BITDW = 16 -- Bowser in the Dark World
COURSE_BITFS = 17 -- Bowser in the Fire Sea
COURSE_BITS = 18 -- Bowser in the Sky
COURSE_PSS = 19 -- Princess's Secret Slide
COURSE_COTMC = 20 -- Cavern of the Metal Cap
COURSE_TOTWC = 21 -- Tower of the Wing Cap
COURSE_VCUTM = 22 -- Vanish Cap Under the Moat
COURSE_WMOTR = 23 -- Winged Mario over the Rainbow
COURSE_SA = 24 -- Secret Aquarium
COURSE_CAKE_END = 25 -- The End (Cake Scene)

COURSE_MIN = 1
COURSE_MAX = 26
COURSE_COUNT = 26

COURSE_STAGES_MAX = 15
COURSE_STAGES_COUNT = 15
COURSE_BONUS_STAGES = 16

-- Cutscene Digits:
--      0: Lakitu flies away after the dance
--      1: The camera rotates around mario
--      2: The camera goes to a closeup of mario
--      3: Bowser keys and the grand star
--      4: Default, used for 100 coin stars, 8 red coin stars in bowser levels, and secret stars

course_dance_cutscenes = {
    {4, 4, 4, 4, 4, 4, 4},
    {0, 0, 0, 2, 2, 2, 4},
    {0, 0, 0, 0, 2, 0, 4},
    {2, 2, 2, 2, 2, 2, 4},
    {0, 0, 2, 2, 0, 0, 4},
    {2, 2, 2, 2, 2, 2, 4},
    {2, 2, 2, 2, 2, 2, 4},
    {2, 1, 2, 1, 2, 1, 4},
    {2, 0, 2, 2, 2, 2, 4},
    {2, 2, 2, 2, 2, 2, 4},
    {0, 2, 0, 2, 0, 2, 4},
    {2, 2, 1, 0, 2, 2, 4},
    {0, 0, 0, 0, 0, 0, 4},
    {1, 1, 1, 1, 2, 1, 4},
    {2, 2, 2, 2, 2, 2, 4},
    {0, 0, 0, 0, 0, 0, 4},
    {3, 4, 4, 4, 4, 4, 4},
    {3, 4, 4, 4, 4, 4, 4},
    {3, 4, 4, 4, 4, 4, 4},
    {2, 4, 4, 4, 4, 4, 4},
    {4, 4, 4, 4, 4, 4, 4},
    {0, 4, 4, 4, 4, 4, 4},
    {2, 4, 4, 4, 4, 4, 4},
    {0, 4, 4, 4, 4, 4, 4},
    {2, 4, 4, 4, 4, 4, 4},
    {4, 4, 4, 4, 4, 4, 4}, 
}

COURSE_CAP_COURSES = COURSE_COTMC
function COURSE_IS_MAIN_COURSE(course)
	return course >= COURSE_MIN and course <= COURSE_MAX
end
