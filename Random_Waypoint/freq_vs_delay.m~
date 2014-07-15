function [ output_args ] = freq_vs_delay( s_input, s_mobility, vs_node )
    freq_x = [];
    delay_y = [];

    for freq =1:5:100
      s_input.GLOBAL_FREQUENCY = freq;
      d = do_transfer(s_mobility,s_input,vs_node);
      
      
      
      
      averages = zeros(s_input.NB_NODES);
      for nodeIndex=1:s_input.NB_NODES
      
      current_time_matrix = zeros(length(d(nodeIndex).v_x),s_input.NB_NODES);
      s = size(current_time_matrix);
      for i = 1:s(1);
          current_time_matrix(i,:) = i;
      end

      delay = current_time_matrix - d(nodeIndex).data; 
      delay = delay * s_input.TIME_STEP;
   
      average_delay = mean(delay,2);
      ave_ave_delay = mean(average_delay);
      averages(nodeIndex) = ave_ave_delay;
      end
      
      %get the average across all nodes
      delay_y = [delay_y,mean(averages)];
      freq_x = [freq_x,freq];
      
      fprintf('added %d-%d',freq,mean(averages));
      
       
   end 


%FREQ_VS_DELAY Summary of this function goes here
%   Detailed explanation goes here


end

