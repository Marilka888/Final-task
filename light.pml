#define BLUE_NS_ROAD_ID 1
#define RED_NE_ROAD_ID 2
#define ORANGE_SN_ROAD_ID 3
#define PURPLE_WN_ROAD_ID 4
#define BLACK_EW_ROAD_ID 5
#define PED_ROAD_ID 6

chan BLUE_LIGHT_CHANNEL = [1] of {byte};
chan RED_LIGHT_CHANNEL = [1] of {byte};
chan ORANGE_LIGHT_CHANNEL = [1] of {byte};
chan PURPLE_LIGHT_CHANNEL = [1] of {byte};
chan BLACK_LIGHT_CHANNEL = [1] of {byte};
chan PED_LIGHT_CHANNEL = [1] of {byte};

byte priority_coef = 10;


short n_requests_per_road [7] = {0,0,0,0,0,0,0};
bool road_sensor_state[7] = {false, false, false, false, false, false, false};
bool traffic_lights_states [7] = {false, false, false, false, false, false, false};


byte current_processed_road_id = 1;


proctype CarTrafficGenerator(){
    do
        :: BLUE_LIGHT_CHANNEL!1
        :: RED_LIGHT_CHANNEL!1
        :: ORANGE_LIGHT_CHANNEL!1
        :: PURPLE_LIGHT_CHANNEL!1
        :: BLACK_LIGHT_CHANNEL!1
    od
}

proctype PedTrafficGenerator(){
    do
        :: PED_LIGHT_CHANNEL!1
    od
}

proctype TrafficLight (byte curr_road_id; byte next_road_id; byte competitor_1; byte competitor_2; byte competitor_3; byte competitor_4; chan traffic_channel){
    short curr_road_value = 0;
    short competitor_1_value = 0;
    short competitor_2_value = 0;
    short competitor_3_value = 0;
    short competitor_4_value = 0;
    byte channel_data = 0;
    do
        :: current_processed_road_id == curr_road_id ->
        if
        :: traffic_channel?channel_data->
                n_requests_per_road[0] = 0; 
                road_sensor_state[curr_road_id] = (channel_data == 1);

                atomic {
                    printf("\n\n\nProcess for road id: %d", curr_road_id);
                    printf("\nN of n_requests_per_road: %d", n_requests_per_road[curr_road_id]);
                    printf("\nCar sensor state: %d", road_sensor_state[curr_road_id]);
                    printf("\nTraffic Light opened: %d", traffic_lights_states[curr_road_id]);
                }

                if
                    :: traffic_lights_states[curr_road_id] == true ->
                        n_requests_per_road[curr_road_id] = 0; 
                        traffic_lights_states[curr_road_id] = false;
                        printf ("\n\n\nClose traffic light for road_id: %d", curr_road_id);
                        printf("\nN n_requests_per_road for this road_id: %d", n_requests_per_road[curr_road_id]);
                    :: else -> skip;
                fi;
                
                if
                :: n_requests_per_road[curr_road_id] > 0 ->
                        printf("\n\n\nAvailable n_requests_per_road for road_id: %d", curr_road_id)
                        if
                        :: (n_requests_per_road[competitor_1] == 0) && 
                            (n_requests_per_road[competitor_2] == 0) && 
                            (n_requests_per_road[competitor_3] == 0) &&
                            (n_requests_per_road[competitor_4] == 0)
                            ->
                                printf("\n\n\nOpen traffic light for road_id: %d", curr_road_id);
                                traffic_lights_states[curr_road_id] = true;
                                road_sensor_state[curr_road_id] = false;
                                current_processed_road_id = next_road_id
                        :: else ->
                                printf("\n\n\nFailed to open traffic light for road_id: %d", curr_road_id);
                                if
                                    :: n_requests_per_road[competitor_1] > 0 -> competitor_1_value = n_requests_per_road[competitor_1];
                                    :: else -> competitor_1_value = 0;
                                fi;
                                if
                                    :: n_requests_per_road[competitor_2] >0 -> competitor_2_value = n_requests_per_road[competitor_2];
                                    :: else -> competitor_2_value = 0;
                                fi;
                                if
                                    :: n_requests_per_road[competitor_3] >0 -> competitor_3_value = n_requests_per_road[competitor_3];
                                    :: else -> competitor_3_value = 0;
                                fi
                                if
                                    :: n_requests_per_road[competitor_4] >0 -> competitor_4_value = n_requests_per_road[competitor_4];
                                    :: else -> competitor_4_value = 0;
                                fi

                                curr_road_value = n_requests_per_road[curr_road_id];
                                
                                atomic {
                                    printf("\n\n\n --- N n_requests_per_road status (BEFORE CHECK) --- ")
            
                                    printf("\n\nN n_requests_per_road for curr road_id %d: %d \nN n_requests_per_road for competitor_1 road_id %d: %d \nN n_requests_per_road for competitor_2 road_id %d: %d \nN n_requests_per_road for competitor_3 road_id %d: %d \nN n_requests_per_road for competitor_4 road_id %d: %d", curr_road_id, curr_road_value, competitor_1, competitor_1_value, competitor_2, competitor_2_value, competitor_3, competitor_3_value, competitor_4, competitor_4_value);
                                }

                                if 
                                    :: competitor_1_value > curr_road_value || competitor_2_value > curr_road_value || competitor_3_value > curr_road_value ->
                                        n_requests_per_road[curr_road_id] = curr_road_value + priority_coef; 
                                        n_requests_per_road[competitor_1] = competitor_1_value + priority_coef;
                                        n_requests_per_road[competitor_2] = competitor_2_value + priority_coef;
                                        n_requests_per_road[competitor_3] = competitor_3_value + priority_coef;
                                        n_requests_per_road[competitor_4] = competitor_4_value + priority_coef;
                                        
                                        printf("\n\n\n --- N n_requests_per_road status (AFTER CHECK, FAILED TO OPEN TRAFFIC LIGHT) --- ")
                                        printf("\n\nN n_requests_per_road for curr road_id %d: %d \nN n_requests_per_road for competitor_1 road_id %d: %d \nN n_requests_per_road for competitor_2 road_id %d: %d \nN n_requests_per_road for competitor_3 road_id %d: %d \nN n_requests_per_road for competitor_4 road_id %d: %d", curr_road_id, n_requests_per_road[curr_road_id], competitor_1, n_requests_per_road[competitor_1], competitor_2, n_requests_per_road[competitor_2], competitor_3, n_requests_per_road[competitor_3], competitor_4, n_requests_per_road[competitor_4]);
                                        skip
                                    :: else ->
                                        printf("\n\n\n --- N n_requests_per_road status (AFTER CHECK, SUCCEEDED TO OPEN TRAFFIC LIGHT) --- ")
                                        printf("\n\nN n_requests_per_road for curr road_id %d: %d \nN n_requests_per_road for competitor_1 road_id %d: %d \nN n_requests_per_road for competitor_2 road_id %d: %d \nN n_requests_per_road for competitor_3 road_id %d: %d \nN n_requests_per_road for competitor_4 road_id %d: %d", curr_road_id, n_requests_per_road[curr_road_id], competitor_1, n_requests_per_road[competitor_1], competitor_2, n_requests_per_road[competitor_2], competitor_3, n_requests_per_road[competitor_3], competitor_4, n_requests_per_road[competitor_4]);
                                        traffic_lights_states[curr_road_id] = true;
                                        road_sensor_state[curr_road_id] = false;
                                        n_requests_per_road[curr_road_id] = 999 + curr_road_id
                                fi;
                        
                        current_processed_road_id = next_road_id;
                        n_requests_per_road[0] = 0;
                        fi
                :: else ->
                        printf("\n\n\nNo n_requests_per_road for road_id: %d", curr_road_id)
                        n_requests_per_road[curr_road_id] = curr_road_id;
                        current_processed_road_id = next_road_id;
                fi;
            fi;
    od
}


init {
    run TrafficLight(BLUE_NS_ROAD_ID, RED_NE_ROAD_ID, PURPLE_WN_ROAD_ID, BLACK_EW_ROAD_ID, 0, 0, BLUE_NS_ROAD_ID);
    run TrafficLight(RED_NE_ROAD_ID, ORANGE_SN_ROAD_ID, ORANGE_SN_ROAD_ID, PURPLE_WN_ROAD_ID, PED_ROAD_ID, BLACK_EW_ROAD_ID, RED_LIGHT_CHANNEL);
    run TrafficLight(ORANGE_SN_ROAD_ID, PURPLE_WN_ROAD_ID, RED_NE_ROAD_ID, BLACK_EW_ROAD_ID, 0, 0, ORANGE_LIGHT_CHANNEL);
    run TrafficLight(PURPLE_WN_ROAD_ID, BLACK_EW_ROAD_ID, BLUE_NS_ROAD_ID, RED_NE_ROAD_ID, BLACK_EW_ROAD_ID, 0, PURPLE_LIGHT_CHANNEL);
    run TrafficLight(BLACK_EW_ROAD_ID, PED_ROAD_ID, RED_NE_ROAD_ID, ORANGE_SN_ROAD_ID, PURPLE_WN_ROAD_ID, BLUE_NS_ROAD_ID, BLACK_LIGHT_CHANNEL);
    run TrafficLight(PED_ROAD_ID, BLUE_NS_ROAD_ID, RED_NE_ROAD_ID, BLACK_EW_ROAD_ID, 0, 0, PED_LIGHT_CHANNEL);

    run CarTrafficGenerator();
    run PedTrafficGenerator();
}

// Safety
ltl safety_1 { [] (!(traffic_lights_states[BLUE_NS_ROAD_ID] == 1 && traffic_lights_states[PURPLE_WN_ROAD_ID] == 1)) }  // Нет пересечений между Blue and Purple
ltl safety_2 { [] (!(traffic_lights_states[BLUE_NS_ROAD_ID] == 1 && traffic_lights_states[BLACK_EW_ROAD_ID] == 1)) } // Нет пересечений между Blue and Black
ltl safety_3 { [] (!(traffic_lights_states[RED_NE_ROAD_ID] == 1 && traffic_lights_states[ORANGE_SN_ROAD_ID] == 1)) }  // Нет пересечений между Red and Orange
ltl safety_4 { [] (!(traffic_lights_states[RED_NE_ROAD_ID] == 1 && traffic_lights_states[PURPLE_WN_ROAD_ID] == 1)) } // Нет пересечений между Red and Purple
ltl safety_5 { [] (!(traffic_lights_states[RED_NE_ROAD_ID] == 1 && traffic_lights_states[PED_ROAD_ID] == 1)) } // Нет пересечений между Red and PED
ltl safety_6 { [] (!(traffic_lights_states[RED_NE_ROAD_ID] == 1 && traffic_lights_states[BLACK_EW_ROAD_ID] == 1)) } // Нет пересечений между Red and Black
ltl safety_7 { [] (!(traffic_lights_states[ORANGE_SN_ROAD_ID] == 1 && traffic_lights_states[BLACK_EW_ROAD_ID] == 1)) } // Нет пересечений между Orange and Black
ltl safety_8 { [] (!(traffic_lights_states[PURPLE_WN_ROAD_ID] == 1 && traffic_lights_states[BLACK_EW_ROAD_ID] == 1)) } // Нет пересечений между Purple and Black
ltl safety_9 { [] (!(traffic_lights_states[PED_ROAD_ID] == 1 && traffic_lights_states[BLACK_EW_ROAD_ID] == 1)) } // Нет пересечений между PED and Black

ltl safety_all {
  [] (!(traffic_lights_states[BLUE_NS_ROAD_ID] == 1 && traffic_lights_states[PURPLE_WN_ROAD_ID] == 1)) &&
  [] (!(traffic_lights_states[BLUE_NS_ROAD_ID] == 1 && traffic_lights_states[BLACK_EW_ROAD_ID] == 1)) &&
  [] (!(traffic_lights_states[RED_NE_ROAD_ID] == 1 && traffic_lights_states[ORANGE_SN_ROAD_ID] == 1)) &&
  [] (!(traffic_lights_states[RED_NE_ROAD_ID] == 1 && traffic_lights_states[PURPLE_WN_ROAD_ID] == 1)) &&
  [] (!(traffic_lights_states[RED_NE_ROAD_ID] == 1 && traffic_lights_states[PED_ROAD_ID] == 1)) &&
  [] (!(traffic_lights_states[RED_NE_ROAD_ID] == 1 && traffic_lights_states[BLACK_EW_ROAD_ID] == 1)) &&
  [] (!(traffic_lights_states[ORANGE_SN_ROAD_ID] == 1 && traffic_lights_states[BLACK_EW_ROAD_ID] == 1)) &&
  [] (!(traffic_lights_states[PURPLE_WN_ROAD_ID] == 1 && traffic_lights_states[BLACK_EW_ROAD_ID] == 1)) &&
  [] (!(traffic_lights_states[PED_ROAD_ID] == 1 && traffic_lights_states[BLACK_EW_ROAD_ID] == 1))
}


// Liveness
ltl liveness_1 { [](road_sensor_state[BLUE_NS_ROAD_ID] && traffic_lights_states[BLUE_NS_ROAD_ID] == 0) -> <> (traffic_lights_states[BLUE_NS_ROAD_ID] == 1) }  // Для BLUE_NS дороги
ltl liveness_2 { [](road_sensor_state[RED_NE_ROAD_ID] && traffic_lights_states[RED_NE_ROAD_ID] == 0) -> <> (traffic_lights_states[RED_NE_ROAD_ID] == 1) }  // Для RED_NE дороги
ltl liveness_3 { [](road_sensor_state[ORANGE_SN_ROAD_ID] && traffic_lights_states[ORANGE_SN_ROAD_ID] == 0) -> <> (traffic_lights_states[ORANGE_SN_ROAD_ID] == 1) } // Для ORANGE_SN дороги
ltl liveness_4 { [](road_sensor_state[PURPLE_WN_ROAD_ID] && traffic_lights_states[PURPLE_WN_ROAD_ID] == 0) -> <> (traffic_lights_states[PURPLE_WN_ROAD_ID] == 1) } // Для PURPLE_WN дороги
ltl liveness_5 { [](road_sensor_state[BLACK_EW_ROAD_ID] && traffic_lights_states[BLACK_EW_ROAD_ID] == 0) -> <> (traffic_lights_states[BLACK_EW_ROAD_ID] == 1) } // Для BLACK_EW дороги
ltl liveness_6 { [](road_sensor_state[PED_ROAD_ID] && traffic_lights_states[PED_ROAD_ID] == 0) -> <> (traffic_lights_states[PED_ROAD_ID] == 1) } // Для PED пешеходника

ltl liveness_all {
  [] ((!((road_sensor_state[BLUE_NS_ROAD_ID] && traffic_lights_states[BLUE_NS_ROAD_ID] == 0)) || <> (traffic_lights_states[BLUE_NS_ROAD_ID] == 1)) &&
      (!((road_sensor_state[RED_NE_ROAD_ID] && traffic_lights_states[RED_NE_ROAD_ID] == 0)) || <> (traffic_lights_states[RED_NE_ROAD_ID]==1)) &&
      (!((road_sensor_state[ORANGE_SN_ROAD_ID] && traffic_lights_states[ORANGE_SN_ROAD_ID] == 0)) || <> (traffic_lights_states[ORANGE_SN_ROAD_ID]==1)) &&
      (!((road_sensor_state[PURPLE_WN_ROAD_ID] && traffic_lights_states[PURPLE_WN_ROAD_ID] == 0)) || <> (traffic_lights_states[PURPLE_WN_ROAD_ID]==1)) &&
      (!((road_sensor_state[BLACK_EW_ROAD_ID] && traffic_lights_states[BLACK_EW_ROAD_ID] == 0)) || <> (traffic_lights_states[BLACK_EW_ROAD_ID]==1)) &&
      (!((road_sensor_state[PED_ROAD_ID] && traffic_lights_states[PED_ROAD_ID] == 0)) || <> (traffic_lights_states[PED_ROAD_ID]==1)))
}

// Fairness
ltl fairness_1 { [] (<> (traffic_lights_states[BLUE_NS_ROAD_ID] == 0)) }  // Для BLUE_NS дороги
ltl fairness_2 { [] (<> (traffic_lights_states[RED_NE_ROAD_ID] == 0)) }  // Для RED_NE дороги
ltl fairness_3 { [] (<> (traffic_lights_states[ORANGE_SN_ROAD_ID] == 0)) }  // Для ORANGE_SN дороги
ltl fairness_4 { [] (<> (traffic_lights_states[PURPLE_WN_ROAD_ID] == 0)) }  // Для PURPLE_WN дороги
ltl fairness_5 { [] (<> (traffic_lights_states[BLACK_EW_ROAD_ID] == 0)) }  // Для BLACK_EW дороги
ltl fairness_6 { [] (<> (traffic_lights_states[PED_ROAD_ID] == 0)) }  // Для PED пешеходника

ltl fairness_all {
  [] (<> (traffic_lights_states[BLUE_NS_ROAD_ID]==0) &&
      <> (traffic_lights_states[RED_NE_ROAD_ID]==0) &&
      <> (traffic_lights_states[ORANGE_SN_ROAD_ID]==0) &&
      <> (traffic_lights_states[PURPLE_WN_ROAD_ID]==0) &&
      <> (traffic_lights_states[BLACK_EW_ROAD_ID]==0) &&
      <> (traffic_lights_states[PED_ROAD_ID]==0))
}