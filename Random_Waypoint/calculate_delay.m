function [ output_args ] = calculate_delay(s_input,vs_node,nodeIndex,source)


   % matrix that has the current time step on every row
   % [1,1,1,1,1,1,1;
   %  2,2,2,2,2,2,2; and so on]
   current_time_matrix = zeros(length(vs_node(nodeIndex).v_x),s_input.NB_NODES);
   s = size(current_time_matrix);
   for i = 1:s(1);
       current_time_matrix(i,:) = i;
   end

   delay = current_time_matrix - vs_node(nodeIndex).data; 
   delay = delay * s_input.TIME_STEP;
   
   average_delay = mean(delay');
   
   x = 1:length(delay);
   x = x*s_input.TIME_STEP;
   
   plot(x,average_delay);

%CALCULATE_DELAY Summary of this function goes here
%   Detailed explanation goes here


end

