bool BLUE_REQ = false;   
bool RED_REQ = false;
bool ORANGE_REQ = false;
bool PURPLE_REQ = false;
bool PED_REQ = false;
bool BLACK_REQ = false;

bool BLUE_SENSE = false;  
bool RED_SENSE = false;
bool ORANGE_SENSE = false;
bool PURPLE_SENSE = false;
bool PED_SENSE = false; 
bool BLACK_SENSE = false;

bool BLUE_LIGHT = false;  
bool RED_LIGHT = false;
bool ORANGE_LIGHT = false;
bool PURPLE_LIGHT = false;
bool PED_LIGHT = false; 
bool BLACK_LIGHT = false;

// ЛОКИ
bool BLUE_LOCK = false;
bool RED_LOCK = false;
bool ORANGE_LOCK = false;
bool PURPLE_LOCK = false;
bool PED_LOCK = false;
bool BLACK_LOCK = false;

byte TURN = 0; // 0: BLUE, 1: RED, 2: ORANGE, 3: PURPLE, 4: BLACK, 5: PED

proctype gen_blue() {
    do
    :: !BLUE_REQ && !BLUE_SENSE ->
        BLUE_SENSE = true;
        BLUE_REQ = true;
    od
}

proctype gen_red() {
    do
    :: !RED_REQ && !RED_SENSE ->
        RED_SENSE = true;
        RED_REQ = true;
    od
}

proctype gen_orange() {
    do
    :: !ORANGE_REQ && !ORANGE_SENSE ->
        ORANGE_SENSE = true;
        ORANGE_REQ = true;
    od
}

proctype gen_purple() {
    do
    :: !PURPLE_REQ && !PURPLE_SENSE ->
        PURPLE_SENSE = true;
        PURPLE_REQ = true;
    od
}

proctype gen_black() {
    do
    :: !BLACK_REQ && !BLACK_SENSE ->
        BLACK_SENSE = true;
        BLACK_REQ = true;
    od
}

proctype gen_ped() {
    do
    :: !PED_REQ && !PED_SENSE ->
        PED_SENSE = true;
        PED_REQ = true;
    od
}

proctype arbiter() {
    do
    :: timeout -> TURN = (TURN + 1) % 6
    od
}

// --- Контроллеры ---

proctype ctrl_blue() {
    do
    :: TURN == 0 && BLUE_REQ && !ORANGE_LOCK && !PED_LOCK ->
        BLUE_LOCK = true;
        BLUE_LIGHT = true;
        do
        :: BLUE_SENSE -> BLUE_SENSE = false
        :: else -> break
        od;
        BLUE_LIGHT = false;
        BLUE_REQ = false;
        BLUE_LOCK = false;
    od
}

proctype ctrl_red() {
    do
    :: TURN == 1 && RED_REQ && !ORANGE_LOCK && !PURPLE_LOCK && !PED_LOCK && !BLACK_LOCK ->
        RED_LOCK = true;
        RED_LIGHT = true;
        do
        :: RED_SENSE -> RED_SENSE = false
        :: else -> break
        od;
        RED_LIGHT = false;
        RED_REQ = false;
        RED_LOCK = false;
    od
}

proctype ctrl_orange() {
    do
    :: TURN == 2 && ORANGE_REQ && !BLUE_LOCK && !RED_LOCK && !PURPLE_LOCK && !PED_LOCK && !BLACK_LOCK ->
        ORANGE_LOCK = true;
        ORANGE_LIGHT = true;
        do
        :: ORANGE_SENSE -> ORANGE_SENSE = false
        :: else -> break
        od;
        ORANGE_LIGHT = false;
        ORANGE_REQ = false;
        ORANGE_LOCK = false;
    od
}

proctype ctrl_purple() {
    do
    :: TURN == 3 && PURPLE_REQ && !RED_LOCK && !ORANGE_LOCK && !PED_LOCK && !BLACK_LOCK ->
        PURPLE_LOCK = true;
        PURPLE_LIGHT = true;
        do
        :: PURPLE_SENSE -> PURPLE_SENSE = false
        :: else -> break
        od;
        PURPLE_LIGHT = false;
        PURPLE_REQ = false;
        PURPLE_LOCK = false;
    od
}

proctype ctrl_black() {
    do
    :: TURN == 4 && BLACK_REQ && !RED_LOCK && !ORANGE_LOCK && !PURPLE_LOCK && !PED_LOCK ->
        BLACK_LOCK = true;
        BLACK_LIGHT = true;
        do
        :: BLACK_SENSE -> BLACK_SENSE = false
        :: else -> break
        od;
        BLACK_LIGHT = false;
        BLACK_REQ = false;
        BLACK_LOCK = false;
    od
}

proctype ctrl_ped() {
    do
    :: TURN == 5 && PED_REQ && !RED_LOCK && !ORANGE_LOCK && !PURPLE_LOCK && !BLACK_LOCK && !BLUE_LOCK ->
        PED_LOCK = true;
        PED_LIGHT = true;
        do
        :: PED_SENSE -> PED_SENSE = false
        :: else -> break
        od;
        PED_LIGHT = false;
        PED_REQ = false;
        PED_LOCK = false;
    od
}

init {
    run arbiter();
    run gen_blue();   run ctrl_blue();
    run gen_red();    run ctrl_red();
    run gen_orange(); run ctrl_orange();
    run gen_purple(); run ctrl_purple();
    run gen_black();  run ctrl_black();
    run gen_ped();    run ctrl_ped();
}

// SAFETY
ltl saf1 { []( !(RED_LIGHT && PED_LIGHT) ) }
ltl saf2 { []( !(BLUE_LIGHT && PED_LIGHT) ) }
ltl saf3 { []( !(ORANGE_LIGHT && PED_LIGHT) ) }
ltl saf4 { []( !(ORANGE_LIGHT && BLUE_LIGHT) ) }
ltl saf5 { []( !(BLACK_LIGHT && PED_LIGHT) ) }
ltl saf6 { []( !(BLACK_LIGHT && ORANGE_LIGHT) ) }
ltl saf7 { []( !(PURPLE_LIGHT && BLACK_LIGHT) ) }
ltl saf8 { []( !(PURPLE_LIGHT && PED_LIGHT) ) }

// LIVENESS
ltl live1 { []( RED_REQ && !RED_LIGHT -> <> RED_LIGHT ) }
ltl live2 { []( ORANGE_REQ && !ORANGE_LIGHT -> <> ORANGE_LIGHT ) }
ltl live3 { []( BLACK_REQ && !BLACK_LIGHT -> <> BLACK_LIGHT ) }
ltl live4 { []( PURPLE_REQ && !PURPLE_LIGHT -> <> PURPLE_LIGHT ) }

// FAIRNESS
ltl fair1 { []<>( !(RED_LIGHT && RED_REQ) ) }
