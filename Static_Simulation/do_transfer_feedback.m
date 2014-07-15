
function [ data ] = do_transfer_correct( parameters, counter )
%DO_TRANSFER_CORRECT Summary of this function goes here
%   Detailed explanation goes here
data = repmat(struct,1,parameters.NR_NODES);

%All entries are initialized to -1
% -1 => nothing heard from that time series
for nodeIndex = 1:parameters.NR_NODES 
   data(nodeIndex).data = repmat( -1, parameters.NR_TIME_STEPS,parameters.NR_NODES);
   data(nodeIndex).counter = randi(counter);
end

for nodeIndex = 1:parameters.NR_NODES
  data(nodeIndex).data(1,nodeIndex) = 0; 
end

for time_step = 1:parameters.NR_TIME_STEPS-1
      %Doubles frequency every 200 seconds
   if mod(time_step,800) == 0
      fprintf('TIME: %d',time_step * parameters.TIME_STEP);
      counter = max([floor(counter - 4),2]);
      fprintf(' SYNCH EVERY %d s \n',counter*parameters.TIME_STEP)
      for nodeIndex = 1:parameters.NR_NODES
          if data(nodeIndex).counter > counter
             data(nodeIndex).counter = counter; 
          end
      end
   end
    
    
    
   for nodeIndex = 1:parameters.NR_NODES
      % Remember old information
      data(nodeIndex).data(time_step + 1,:) = data(nodeIndex).data(time_step,:);
      
      % Put timestamp for own time series last_synch
      data(nodeIndex).data(time_step + 1,nodeIndex) = time_step;
   end
   
   for nodeIndex = 1:parameters.NR_NODES
      
      if data(nodeIndex).counter == 0
         
        destination = pick_random_link(parameters.links(nodeIndex,:),parameters.NR_NODES);
        
        for data_from = 1:parameters.NR_NODES
           % if the destination has older data than the local, transfer it
           if data(destination).data(time_step + 1,data_from) < ...
              data(nodeIndex).data(time_step,data_from)
         
              data(destination).data(time_step + 1,data_from) = ...
              data(nodeIndex).data(time_step,data_from);
          
           end
               
        end
      
      data(nodeIndex).counter = counter;
      else
      data(nodeIndex).counter = data(nodeIndex).counter - 1;
      end
   end
   %pick a random link
        % send own timestamp to next time_step for ORIGINAL
        % forward any information to the next step
        
        
    
    
end


end

function [ destination ] = pick_random_link(link_list,NR_NODES)
    links_to_choose = zeros(1,NR_NODES);
    last_filled = 1;
    total_number = 0;
    for i = 1:NR_NODES
        if link_list(i) == 1
            links_to_choose(last_filled) = i;
            last_filled = last_filled + 1;
            total_number = total_number + 1; 
         end
     end
         
     if total_number == 0
         fprintf('NO NEIGHBOURS: %d',nodeIndex); 
     end
         
     if total_number > 0
        link_index_chosen = randi(total_number);
        destination = links_to_choose(link_index_chosen);
     end
end

