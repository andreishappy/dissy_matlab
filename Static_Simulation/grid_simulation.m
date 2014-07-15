clear all;clc;close all;
%GENERATES A SQUARE GRID OF NODES
%================================

%PARAMETERS:
parameters = struct;
parameters.GRID_SIZE = 6;
parameters.CONNECTIVITY_THRESHOLD = 1.6;
parameters.NR_NODES = parameters.GRID_SIZE * parameters.GRID_SIZE;
parameters.SIMULATION_DURATION = 2400; % in seconds
parameters.TIME_STEP = .5; 
parameters.NR_TIME_STEPS = parameters.SIMULATION_DURATION / ...
                           parameters.TIME_STEP + 1;
parameters.DEFAULT_COUNTER = 50;

%POSITION GENERATION
x_positions = zeros(1,parameters.NR_NODES);
y_positions = zeros(1,parameters.NR_NODES);

index = 1;

for x = 0:parameters.GRID_SIZE - 1
   for y = 0:parameters.GRID_SIZE - 1
      x_positions(index) = x;
      y_positions(index) = y;
      index = index + 1;
   end
end

%LINK GENERATION
parameters.links = zeros(parameters.NR_NODES,parameters.NR_NODES);

for nodeIndex = 1:parameters.NR_NODES
   for destinationIndex = 1:parameters.NR_NODES
       if nodeIndex ~= destinationIndex && ...
          sqrt( (x_positions(nodeIndex) - x_positions(destinationIndex))^2 + ...
                (y_positions(nodeIndex) - y_positions(destinationIndex))^2 ) ...
                < parameters.CONNECTIVITY_THRESHOLD
               
          parameters.links(nodeIndex,destinationIndex) = 1;
       end
    end
end

disp('generated the link matrix');


data = do_transfer_correct(parameters,20);
graph_delay_over_time(parameters,data,6,19);


% freqs = 2;
% averages = [];
% for i = freqs
%     data = do_transfer(parameters,i);
%     
%     averages = [ averages calculate_average_delay_one_consumer(parameters,data,2)];
%     fprintf('done %d',i)
% end
% %plot(freqs,averages)


