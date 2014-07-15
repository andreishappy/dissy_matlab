function rer = do_transfer(s_mobility,s_input,vs_node)
   

   for nodeIndex = 1:s_mobility.NB_NODES
      vs_node(nodeIndex).counter = randi([0,s_input.GLOBAL_FREQUENCY]);
   end
   
   
   for time_step = 1:s_input(NB_TIME_STEPS);       
       
        for nodeIndex = 1:s_mobility.NB_NODES 
    
         %remember all the past data
         if time_step > 1
            vs_node(nodeIndex).data(time_step,:) = vs_node(nodeIndex).data(time_step-1,:);
         end
         
        end
       
       %Send the data to one random neighbour
          for nodeIndex = 1:s_mobility.NB_NODES
           %Check if it's time to synchronize
           if vs_node(nodeIndex).counter == 0
         
             %send data the local monitor produces
             link_to_pick = randperm(length(vs_node(nodeIndex).links{time_step}));
             if numel(link_to_pick) > 0
                link_to_pick = link_to_pick(1);
                destination_id = vs_node(nodeIndex).links{time_step}(link_to_pick);
                vs_node(destination_id).data(time_step,nodeIndex) = time_step;
%                 fprintf('TIME %d: MADE AN ORIGINAL TRANSFER FROM %d TO %d\n',...
%                      time_step,nodeIndex,destination_id)
%              
                %send data that I have from others
                for index = 1:s_input.NB_NODES
                   if vs_node(destination_id).data(time_step,index) < ...
                      vs_node(nodeIndex).data(time_step,index)
                   
                      vs_node(destination_id).data(time_step,index) = ...
                      vs_node(nodeIndex).data(time_step,index);
%                       fprintf('TIME %d: FORWARD FROM %d TO %d\n',...
%                      time_step,nodeIndex,destination_id)
                   end
                end
             end
             vs_node(nodeIndex).counter = s_input.GLOBAL_FREQUENCY;
           else
             vs_node(nodeIndex).counter = vs_node(nodeIndex).counter - 1;
           end
          end
   end
   
   
%DO_TRANSFER Summary of this function goes here
%   Detailed explanation goes here
   rer = vs_node;

end

