function [ output,s_mobility ] = get_links( s_input )
    s_mobility = Generate_Mobility(s_input);
    
    v_t = 0:s_input.TIME_STEP:s_input.SIMULATION_TIME;
    
    output = repmat(struct,1,s_input.NB_NODES);
    
    for nodeIndex = 1:s_mobility.NB_NODES
        %Simple interpolation (linear) to get the position, anytime.
        %Remember that "interp1" is the matlab function to use in order to
        %get nodes' position at any continuous time.
        output(nodeIndex).id = nodeIndex;
        output(nodeIndex).v_x = interp1(s_mobility.VS_NODE(nodeIndex).V_TIME,s_mobility.VS_NODE(nodeIndex).V_POSITION_X,v_t);
        output(nodeIndex).v_y = interp1(s_mobility.VS_NODE(nodeIndex).V_TIME,s_mobility.VS_NODE(nodeIndex).V_POSITION_Y,v_t);
        
        %Added for keeping track of links at every time step
        number_time_steps = length(output(nodeIndex).v_x);
        output(nodeIndex).NB_TIME_STEPS = number_time_steps;
        output(nodeIndex).links = zeros(number_time_steps,s_input.NB_NODES);
        
        
        %Keep track of last received data
        output(nodeIndex).data = zeros(number_time_steps,s_input.NB_NODES);
    end

   %Now vs_node(index).v_x and .v_y) have the positions at increments of
   %time_step


    for nodeIndex = 1:s_mobility.NB_NODES
       for time_step = 1:number_time_steps
           
          for destination = 1:s_mobility.NB_NODES
             if destination ~= nodeIndex
                if sqrt( (output(nodeIndex).v_x(time_step) - output(destination).v_x(time_step)) ^2 + ...
                             (output(nodeIndex).v_y(time_step) - output(destination).v_y(time_step)) ^2 ) < s_input.LINK_DISTANCE_THRESHOLD
                       output(nodeIndex).links(time_step,destination) = 1;
%                        fprintf('Added link %d -> %d\n',nodeIndex,destination);
                end
             end
          end
        end
        fprintf('%d nodes DONE\n',nodeIndex); 
    end 

   display('Mobility DONE');
   
   
%GET_LINKS Summary of this function goes here
%   Detailed explanation goes here


end

