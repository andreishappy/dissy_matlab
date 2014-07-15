function [ output_average ] = find_average_delay( s_input,link_output,data )
%FIND_AVERAGE_DELAY Summary of this function goes here
%   Detailed explanation goes here

   all_node_averages = zeros(1,s_input.NB_NODES);
   
   current_time = zeros(link_output(1).NB_TIME_STEPS,s_input.NB_NODES);
   for i = 1:link_output(1).NB_TIME_STEPS
      current_time(i,:) = i-1; 
   end
   disp('current time calculated')
   
   for nodeIndex= 1:s_input.NB_NODES
      average_for_destination = mean(current_time - data(nodeIndex).data,1);
      all_node_averages(nodeIndex) = mean(average_for_destination);
   end
   format short
   output_average = mean(all_node_averages*s_input.TIME_STEP);
   
end

