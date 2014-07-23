clear all;clc;close all;



parameters = struct;
parameters.SIMULATION_DURATION = 300; % in seconds
parameters.TIME_STEP = .05;
parameters.NR_TIME_STEPS = parameters.SIMULATION_DURATION / ...
                           parameters.TIME_STEP + 1;

grid_size = 6;                    
connectivity_threshold = 2;
links = create_grid_links(grid_size,connectivity_threshold,parameters);

parameters.NR_NODES = grid_size*grid_size;
parameters.DEFAULT_COUNTER = 20;
% [control, already_heard, already_heard_counter] = do_feedback(links,parameters);

tic;

[data] = do_transfer_feedback(parameters,links);
% [data] = do_feedback(links,parameters);
toc;

graph_delay_over_time_multiple(parameters,data,[2,26],[4,28]);

