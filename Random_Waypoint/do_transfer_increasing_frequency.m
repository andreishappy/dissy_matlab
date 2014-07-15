function [ data ] = do_transfer_increasing_frequency( s_input, link_output)
%DO_TRANSFER_NEW Summary of this function goes here
%   Detailed explanation goes here
   data = repmat(struct,1,s_input.NB_NODES);
   
   
   for nodeIndex = 1:s_input.NB_NODES
      data(nodeIndex).counter = randi([0,s_input.GLOBAL_FREQUENCY]);
      data(nodeIndex).data = zeros(link_output(1).NB_TIME_STEPS,s_input.NB_NODES);
   end
   
   
   for time_step = 1:link_output(1).NB_TIME_STEPS;       
       
        for nodeIndex = 1:s_input.NB_NODES 
    
         %remember all the past data
         if time_step > 1
            data(nodeIndex).data(time_step,:) = data(nodeIndex).data(time_step-1,:);
         end
         
        end
      
      if mod(time_step*s_input.TIME_STEP,400) == 0
         fprintf('increased frequency to %d',max([4,floor(s_input.GLOBAL_FREQUENCY / 2)]) );
         s_input.GLOBAL_FREQUENCY = max([4,floor(s_input.GLOBAL_FREQUENCY / 2)]); 
         for nodeIndex = 1:s_input.NB_NODES  
             if data(nodeIndex).counter > s_input.GLOBAL_FREQUENCY
                data(nodeIndex).counter = s_input.GLOBAL_FREQUENCY;
             end
         end
      end
       %Send the data to one random neighbour
      for nodeIndex = 1:s_input.NB_NODES
         %Check if it's time to synchronize
         if data(nodeIndex).counter == 0
            links = zeros(1,s_input.NB_NODES);
            last_filled = 1;
            total_number = 0;
            for index=1:s_input.NB_NODES
               if link_output(nodeIndex).links(time_step,index) ~= 0
                  links(last_filled) = index;
                  last_filled = last_filled + 1;
                  total_number = total_number + 1;                   
               end
            end
            
            if total_number > 0
               link_index_to_pick = randi(total_number);
               destination_id = links(link_index_to_pick);
            
               %Make original transfers
               data(destination_id).data(time_step,nodeIndex) = time_step - 1;
%                fprintf('TIME %d: MADE AN ORIGINAL TRANSFER FROM %d TO %d\n',...
%                         time_step,nodeIndex,destination_id)
               %Transfer any newer data to the destination picked
               for index = 1:s_input.NB_NODES
                  if data(destination_id).data(time_step,index) < ...
                     data(nodeIndex).data(time_step,index)
              
                     data(destination_id).data(time_step,index) = ...
                     data(nodeIndex).data(time_step,index);
                     
%                      fprintf('TIME %d: FORWARD FROM %d TO %d\n',...
%                              time_step,nodeIndex,destination_id);
                  end 
               end
            end
         data(nodeIndex).counter = s_input.GLOBAL_FREQUENCY;
         else
         data(nodeIndex).counter = data(nodeIndex).counter - 1;
         end
      end
   end
   
end
                
                
         
   

