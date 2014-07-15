function [ link_output ] = create_grid_links( grid_size, connectivity_threshold, parameters )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

NR_NODES = grid_size * grid_size;

%POSITION GENERATION
x_positions = zeros(1,NR_NODES);
y_positions = zeros(1,NR_NODES);

index = 1;

for x = 0:grid_size - 1
   for y = 0:grid_size - 1
      x_positions(index) = x;
      y_positions(index) = y;
      index = index + 1;
   end
end

%LINK GENERATION
link_output = repmat(struct,1,NR_NODES);

for nodeIndex = 1:NR_NODES
   links = zeros(1,NR_NODES);
   last_index_changed = 1;

   for destinationIndex = 1:NR_NODES
       if nodeIndex ~= destinationIndex && ...
          sqrt( (x_positions(nodeIndex) - x_positions(destinationIndex))^2 + ...
                (y_positions(nodeIndex) - y_positions(destinationIndex))^2 ) ...
                < connectivity_threshold;
               
          links(last_index_changed) = destinationIndex;
          last_index_changed = last_index_changed + 1;
       end              
   end
   
   link_output(nodeIndex).links = repmat(links,parameters.NR_TIME_STEPS,1);
   link_output(nodeIndex).link_count = repmat(last_index_changed -1 ,parameters.NR_TIME_STEPS,1);
   
 end

end

