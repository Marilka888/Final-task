// Blue (N->S)
// Red (N->E)
// Orange (S->N)
// Purple (W->N)
// PED
// Black (E->W)


// запросы на проезд/проход
bool BLUE_REQ = false;   
bool RED_REQ = false;
bool ORANGE_REQ = false;
bool PURPLE_REQ = false;
bool PED_REQ = false;
bool BLACK_REQ = false;
// наличие машины/пешеходов    
bool BLUE_SENSE = false;  
bool RED_SENSE = false;
bool ORANGE_SENSE = false;
bool PURPLE_SENSE = false;
bool PED_SENSE = false; 
bool BLACK_SENSE = false;
// светофор: true = GREEN, false = RED
bool BLUE_LIGHT = false;  
bool RED_LIGHT = false;
bool ORANGE_LIGHT = false;
bool PURPLE_LIGHT = false;
bool PED_LIGHT = false; 
bool BLACK_LIGHT = false;

// флаги конфликтов
bool CONFLICT_LOCK = false;   
bool BLACK_LOCK = false;
bool ORANGE_LOCK = false;
bool BLUE_PED_LOCK = false;

byte TURN = 0; // 0: BLUE, 1: RED, 2: ORANGE, 3: PURPLE, 4: BLACK, 5: PED

// Генерация машин (трафика)
proctype gen_blue() {
    do
    :: true ->
        if
        :: !BLUE_REQ && !BLUE_SENSE ->
            BLUE_SENSE = true;
            BLUE_REQ = true;
        :: else -> skip
        fi;
    od
}

proctype gen_red() {
    do
    :: true ->
        if
        :: !RED_REQ && !RED_SENSE ->
            RED_SENSE = true;
            RED_REQ = true;
        :: else -> skip
        fi;
    od
}

proctype gen_orange() {
    do
    :: true ->
        if
        :: !ORANGE_REQ && !ORANGE_SENSE ->
            ORANGE_SENSE = true;
            ORANGE_REQ = true;
        :: else -> skip
        fi;
    od
}

proctype gen_purple() {
    do
    :: true ->
        if
        :: !PURPLE_REQ && !PURPLE_SENSE ->
            PURPLE_SENSE = true;
            PURPLE_REQ = true;
        :: else -> skip
        fi;
    od
}

proctype gen_black() {
    do
    :: true ->
        if
        :: !BLACK_REQ && !BLACK_SENSE ->
            BLACK_SENSE = true;
            BLACK_REQ = true;
        :: else -> skip
        fi;
    od
}

// Генерация пешеходов
proctype gen_ped() {
    do
    :: true ->
        if
        :: !PED_REQ && !PED_SENSE ->
            PED_SENSE = true;
            PED_REQ = true;
        :: else -> skip
        fi;
    od
}

// контроллеры
proctype arbiter() {
    do
    :: timeout -> TURN = (TURN + 1) % 6
    od
}


proctype ctrl_blue() {
    do
    :: BLUE_REQ && TURN == 0 && !BLUE_PED_LOCK ->
        BLUE_PED_LOCK = true;
        BLUE_LIGHT = true;

        do
        :: BLUE_SENSE -> BLUE_SENSE = false
        :: else -> break
        od;

        BLUE_LIGHT = false;
        BLUE_REQ = false;
        BLUE_PED_LOCK = false;
    od
}

proctype ctrl_red() {
    do
    :: RED_REQ && TURN == 1 && !BLUE_PED_LOCK ->
        BLUE_PED_LOCK = true;
        RED_LIGHT = true;

        do
        :: RED_SENSE -> RED_SENSE = false
        :: else -> break
        od;

        RED_LIGHT = false;
        RED_REQ = false;
        BLUE_PED_LOCK = false;
    od
}

proctype ctrl_orange() {
    do
    :: ORANGE_REQ && TURN == 2 && !BLUE_PED_LOCK && !ORANGE_LOCK ->
        BLUE_PED_LOCK = true;
        ORANGE_LOCK = true;
        ORANGE_LIGHT = true;

        do
        :: ORANGE_SENSE -> ORANGE_SENSE = false
        :: else -> break
        od;

        ORANGE_LIGHT = false;
        ORANGE_REQ = false;
        ORANGE_LOCK = false;
        BLUE_PED_LOCK = false;
    od
}

proctype ctrl_purple() {
    do
    :: PURPLE_REQ && TURN == 3 ->
        BLUE_PED_LOCK = true;
        BLACK_LOCK = true;
        PURPLE_LIGHT = true;

        do
        :: PURPLE_SENSE -> PURPLE_SENSE = false
        :: else -> break
        od;

        PURPLE_LIGHT = false;
        PURPLE_REQ = false;
        BLACK_LOCK = false;
        BLUE_PED_LOCK = false;
    od
}


proctype ctrl_black() {
    do
    :: BLACK_REQ && TURN == 4 && !BLUE_PED_LOCK && !BLACK_LOCK ->
        BLUE_PED_LOCK = true;
        BLACK_LOCK = true;
        BLACK_LIGHT = true;

        do
        :: BLACK_SENSE -> BLACK_SENSE = false
        :: else -> break
        od;

        BLACK_LIGHT = false;
        BLACK_REQ = false;
        BLACK_LOCK = false;
        BLUE_PED_LOCK = false;
    od
}

proctype ctrl_ped() {
    do
    :: PED_REQ && TURN == 5 && !BLUE_PED_LOCK ->
        BLUE_PED_LOCK = true;
        PED_LIGHT = true;

        do
        :: PED_SENSE -> PED_SENSE = false
        :: else -> break
        od;

        PED_LIGHT = false;
        PED_REQ = false;
        BLUE_PED_LOCK = false;
    od
}

init {
    run arbiter();
    run gen_purple();   run ctrl_purple();
}




// SAFETY: нельзя одновременно PED и RED
ltl saf1 { []( !(RED_LIGHT && PED_LIGHT) ) }

// SAFETY: нельзя одновременно PED и BLUE
ltl saf2 { []( !(BLUE_LIGHT && PED_LIGHT) ) }

// LIVENESS: если есть запрос RED, то будет зелёный
ltl live1 { []( RED_REQ && !RED_LIGHT -> <> RED_LIGHT ) }

// FAIRNESS: RED не может вечно быть зелёным при наличии запросов
ltl fair1 { []<>( !(RED_LIGHT && RED_REQ) ) }

// SAFETY: нельзя одновременно Orange и PED
ltl saf3 { []( !(ORANGE_LIGHT && PED_LIGHT) ) }

// SAFETY: нельзя Orange и Blue одновременно (если по матрице есть конфликт)
ltl saf4 { []( !(ORANGE_LIGHT && BLUE_LIGHT) ) }

// LIVENESS: если есть запрос, будет зелёный
ltl live2 { []( ORANGE_REQ && !ORANGE_LIGHT -> <> ORANGE_LIGHT ) }

// SAFETY: PED и Black не одновременно
ltl saf5 { []( !(BLACK_LIGHT && PED_LIGHT) ) }

// SAFETY: Black и Orange не одновременно
ltl saf6 { []( !(BLACK_LIGHT && ORANGE_LIGHT) ) }

// LIVENESS: если есть машина, включится зелёный
ltl live3 { []( BLACK_REQ && !BLACK_LIGHT -> <> BLACK_LIGHT ) }

// SAFETY: Purple и Black не одновременно
ltl saf7 { []( !(PURPLE_LIGHT && BLACK_LIGHT) ) }

// SAFETY: Purple и PED не одновременно
ltl saf8 { []( !(PURPLE_LIGHT && PED_LIGHT) ) }

// LIVENESS: если запрос — зелёный включится
ltl live4 { []( PURPLE_REQ && !PURPLE_LIGHT -> <> PURPLE_LIGHT ) }
