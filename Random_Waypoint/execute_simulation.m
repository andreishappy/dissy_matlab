clear all;clc;close all;



s_input = struct('V_POSITION_X_INTERVAL',[0 1000],...%(m)
                 'V_POSITION_Y_INTERVAL',[0 1000],...%(m)
                 'V_SPEED_INTERVAL',[0.2 2],...%(m/s)
                 'V_PAUSE_INTERVAL',[0 1],...%pause time (s)
                 'V_WALK_INTERVAL',[2.00 80],...%walk time (s)
                 'V_DIRECTION_INTERVAL',[-180 180],...%(degrees)
                 'SIMULATION_TIME',2400,...%(s)
                 'NB_NODES',50, ...
                 'GLOBAL_FREQUENCY',40,...
                 'TIME_STEP',.25,...
                 'LINK_DISTANCE_THRESHOLD', 200);

[link_output,s_mobility] = get_links(s_input);

