clear all;clc;close all;



s_input = struct('V_POSITION_X_INTERVAL',[0 1000],...%(m)
                 'V_POSITION_Y_INTERVAL',[0 1000],...%(m)
                 'V_SPEED_INTERVAL',[1.5 4],...%(m/s)
                 'V_PAUSE_INTERVAL',[0 1],...%pause time (s)
                 'V_WALK_INTERVAL',[40 60],...%walk time (s)
                 'V_DIRECTION_INTERVAL',[-180 180],...%(degrees)
                 'SIMULATION_TIME',100,...%(s)
                 'NB_NODES',52, ...
                 'GLOBAL_FREQUENCY',40,...
                 'TIME_STEP',.25,...
                 'LINK_DISTANCE_THRESHOLD', 140);

s_input.NR_TIME_STEPS = s_input.SIMULATION_TIME / s_input.TIME_STEP;
assert(mod(s_input.NR_TIME_STEPS,1)==0);
             
             
[link_output,s_mobility,s_input] = get_links(s_input);

% data = do_ant (s_input,s_mobility,link_output);
data = do_ant_latest_only(s_input,s_mobility,link_output);


% animate_simulation(s_input,s_mobility,link_output);
