clear all;clc;close all;



s_input = struct('V_POSITION_X_INTERVAL',[10 30],...%(m)
                 'V_POSITION_Y_INTERVAL',[10 30],...%(m)
                 'V_SPEED_INTERVAL',[0.2 2.2],...%(m/s)
                 'V_PAUSE_INTERVAL',[0 1],...%pause time (s)
                 'V_WALK_INTERVAL',[2.00 6.00],...%walk time (s)
                 'V_DIRECTION_INTERVAL',[-180 180],...%(degrees)
                 'SIMULATION_TIME',5000,...%(s)
                 'NB_NODES',50, ...
                 'GLOBAL_FREQUENCY',100,...
                 'TIME_STEP',0.1,...
                 'LINK_DISTANCE_THRESHOLD', 5);
s_mobility = Generate_Mobility(s_input);



v_t = 0:s_input.TIME_STEP:s_input.SIMULATION_TIME;
    

    for nodeIndex = 1:s_mobility.NB_NODES
        %Simple interpolation (linear) to get the position, anytime.
        %Remember that "interp1" is the matlab function to use in order to
        %get nodes' position at any continuous time.
        vs_node(nodeIndex).id = nodeIndex;
        vs_node(nodeIndex).v_x = interp1(s_mobility.VS_NODE(nodeIndex).V_TIME,s_mobility.VS_NODE(nodeIndex).V_POSITION_X,v_t);
        vs_node(nodeIndex).v_y = interp1(s_mobility.VS_NODE(nodeIndex).V_TIME,s_mobility.VS_NODE(nodeIndex).V_POSITION_Y,v_t);
        
        %Added for keeping track of links at every time step
        number_time_steps = length(vs_node(nodeIndex).v_x);
        s_input.NB_TIME_STEPS = number_time_steps;
        vs_node(nodeIndex).links = zeros(number_time_steps,s_input.NB_NODES);
        
        
        %Keep track of last received data
        vs_node(nodeIndex).data = zeros(number_time_steps,s_input.NB_NODES);
    end

 %Now vs_node(index).v_x and .v_y) have the positions at increments of
 %time_step
display('Mobility DONE');
    
    for nodeIndex = 1:s_mobility.NB_NODES
        for time_step = 1:number_time_steps
           
            for destination = 1:s_mobility.NB_NODES
                if destination ~= nodeIndex
                    if sqrt( (vs_node(nodeIndex).v_x(time_step) - vs_node(destination).v_y(time_step)) ^2 + ...
                             (vs_node(nodeIndex).v_y(time_step) - vs_node(destination).v_y(time_step)) ^2 ) < s_input.LINK_DISTANCE_THRESHOLD
                       vs_node(nodeIndex).links(time_step,destination) = 1;
                    end
                end
            end
        end
        fprintf('%d nodes DONE\n',nodeIndex); 
    end
    
    