
function [ data ] = do_transfer_feedback( parameters, links )

MESSAGE_DELAY_SECONDS = .05;
MESSAGE_DELAY = MESSAGE_DELAY_SECONDS / parameters.TIME_STEP;
assert(mod(MESSAGE_DELAY,1) == 0, 'MESSAGE_DELAY is not a whole number');

SYNCH_FREQUENCY = 1;%s
COUNTER = SYNCH_FREQUENCY/parameters.TIME_STEP;%time_steps
%Check that the counter is a whole number
assert(mod(COUNTER,1) == 0, 'Sych Counter is not a whole number');





% RUNNING_AVERAGE_FREQUENCY = 5;%s
% RUNNING_AVERAGE_COUNTER = RUNNING_AVERAGE_FREQUENCY / parameters.TIME_STEP;%time steps
% assert(mod(RUNNING_AVERAGE_COUNTER,1) == 0, 'Running Average Counter is not a whole number');

WARMUP_TIME = 20;%s
WARMUP_DONE = WARMUP_TIME / parameters.TIME_STEP;%time periods
assert(mod(WARMUP_DONE,1) == 0, 'WARUMUP_DONE is not a whole number');

% USED TO CALCULATE RUNNING AVERAGES AT EVERY TIME STEP
% UNNECESSARY FOR ALGORITHM AS THEY CAN BE CALCULATED ON THE SPOT

% NR_RUNNING_AVERAGES = parameters.NR_TIME_STEPS - WARMUP_DONE;
% assert(mod(NR_RUNNING_AVERAGES,1) == 0, 'NR_RUNNING_AVERAGES is not a whole number');

FEEDBACK_FREQUENCY = 5;%s
FEEDBACK_COUNTER = FEEDBACK_FREQUENCY / parameters.TIME_STEP;%time steps
assert(mod(FEEDBACK_COUNTER,1) == 0, 'Feedback Counter is not a whole number');
NR_FEEDBACK_RUNNING_AVERAGES = ceil(parameters.NR_TIME_STEPS / FEEDBACK_COUNTER) - WARMUP_DONE;



TIME_PER_RUNNING_AVERAGE = 20;%s
RUNNING_AVERAGE_BUFFER_SIZE = TIME_PER_RUNNING_AVERAGE / parameters.TIME_STEP;


% TO DELETE
UP_TRIGGER = 41;
DOWN_TRIGGER = 22;


data = repmat(struct,1,parameters.NR_NODES);

for nodeIndex = 1:parameters.NR_NODES 
%  All entries are initialized to -1
%  -1 => nothing heard from that time series
   data(nodeIndex).data = zeros(parameters.NR_NODES,parameters.NR_TIME_STEPS);
   
   data(nodeIndex).synch_counter_max = COUNTER;
   data(nodeIndex).synch_counter = randi(data(nodeIndex).synch_counter_max);
   
   data(nodeIndex).feedback_counter = FEEDBACK_COUNTER;
   data(nodeIndex).delays = zeros(parameters.NR_NODES,RUNNING_AVERAGE_BUFFER_SIZE);
   data(nodeIndex).delays_counter = 1;
%  USED TO CALCULATE RUNNING AVERAGES AT EVERY TIME STEP
%  UNNECESSARY FOR ALGORITHM AS THEY CAN BE CALCULATED ON THE SPOT
%    data(nodeIndex).running_average_counter = 1;
%    data(nodeIndex).running_averages = zeros(NR_RUNNING_AVERAGES,parameters.NR_NODES);

   data(nodeIndex).feedback_running_averages = zeros(parameters.NR_NODES,NR_FEEDBACK_RUNNING_AVERAGES);
   data(nodeIndex).feedback_running_averages_counter = 1;

   %USED FOR CHANGING PERIOD ACCORDING TO PACKET PERIOD AND DELAY
   data(nodeIndex).packet_period = zeros(parameters.NR_TIME_STEPS,1);
   data(nodeIndex).packet_delay = zeros(parameters.NR_TIME_STEPS,1);
   data(nodeIndex).previous_packet_synched = repmat(-1,parameters.NR_NODES,1);
   
   %USED FOR DEBUGGING
   data(nodeIndex).all_delays = zeros(parameters.NR_NODES,parameters.NR_TIME_STEPS);
end

   useful_mask = zeros(parameters.NR_NODES,1);
   node_indices = [1:parameters.NR_NODES]';
   packet_delays = zeros(parameters.NR_NODES,1);
   packet_periods = zeros(parameters.NR_NODES,1);
   useful_packet_periods = zeros(parameters.NR_NODES,1);
   min_packet_period = -1;
    
   no_new_data = repmat(0,parameters.NR_NODES,1);
   
   
   
% Initialize own time series
for nodeIndex = 1:parameters.NR_NODES
   data(nodeIndex).data(nodeIndex,1) = 1; 
end

for time_step = 1:parameters.NR_TIME_STEPS-MESSAGE_DELAY

    
   
    
   % DELAY LOG LOOP 
   for nodeIndex = 1:parameters.NR_NODES
      %log value to be used for average
      current_time = repmat(time_step,parameters.NR_NODES,1);
      
      data(nodeIndex).delays(:,data(nodeIndex).delays_counter) = (current_time - data(nodeIndex).data(:,time_step)) * parameters.TIME_STEP;
      data(nodeIndex).delays_counter = increment_cyclical_counter(data(nodeIndex).delays_counter,RUNNING_AVERAGE_BUFFER_SIZE);
      
      %USED FOR DEBUG
      data(nodeIndex).all_delays(:,time_step) = (current_time - data(nodeIndex).data(:,time_step)) * parameters.TIME_STEP;
      
      
      %TO DELETE OR CHANGE FOR ACTUAL FEEDBACK
      if time_step > WARMUP_DONE 
         %calculate running average at every time step
%          data(nodeIndex).running_averages(data(nodeIndex).running_average_counter,:) = mean(data(nodeIndex).delays,2);
         
         if data(nodeIndex).feedback_counter == 0   
              data(nodeIndex).feedback_running_averages(:,data(nodeIndex).feedback_running_averages_counter) = mean(data(nodeIndex).delays,2);
%             %TO DELETE checking feedback based on data
%             if nodeIndex == 2
%                 if data(nodeIndex).running_averages(data(nodeIndex).running_average_counter,36) > UP_TRIGGER
%                     disp('UP')
%                 end
%                 
%                 if data(nodeIndex).running_averages(data(nodeIndex).running_average_counter,36) < DOWN_TRIGGER
%                     disp('DOWN')
%                 end
%                 
%                 
%             end

%             fprintf('NODE: %d Wrote running_average at index %d\n',nodeIndex,data(nodeIndex).running_average_counter);
            
            data(nodeIndex).feedback_counter = FEEDBACK_COUNTER;
            data(nodeIndex).feedback_running_averages_counter = data(nodeIndex).feedback_running_averages_counter + 1;
         else
            data(nodeIndex).feedback_counter = data(nodeIndex).feedback_counter -1;
         end
            
%          data(nodeIndex).running_average_counter = data(nodeIndex).running_average_counter + 1;
      end

   end

   for nodeIndex = 1:parameters.NR_NODES
      if nodeIndex == 2
         data(nodeIndex).packet_period(time_step) = 1; 
         data(nodeIndex).packet_delay(time_step) = 50;
      elseif nodeIndex == 20
         data(nodeIndex).packet_period(time_step) = 2; 
         data(nodeIndex).packet_delay(time_step) = 10;
      else
         data(nodeIndex).packet_period(time_step) = 1000;
      end
   end
   
   
   %set own counter according to the one in the packet if new message
   %received
for nodeIndex = 1:parameters.NR_NODES
   if time_step > 1 && ...
      new_messages(data(nodeIndex).data(:,time_step), data(nodeIndex).data(:,time_step-1),nodeIndex, parameters.NR_NODES)
       fprintf('TIME: %d NODE: %d NEW MESSAGE\n', time_step, nodeIndex);
       %data(nodeIndex).data(:,time_step)
       %data(nodeIndex).data(:,time_step-1)
       for nodeIndex = 1:parameters.NR_NODES
           %FIND THE PACKET DELAYS OF THE MOST RECENT PACKETS
           for source = 1:parameters.NR_NODES

              % If a consumer has not synched with a producer yet, then the
              % delay of that producer should not be included
              if data(nodeIndex).data(source,time_step) == 0
                 packet_delays(source) = -1;
              else

                 packet_delays(source) = data(source).packet_delay(data(nodeIndex).data(source,time_step)); 
                 packet_periods(source) = data(source).packet_period(data(nodeIndex).data(source,time_step));
              end

           end

           % Tells us which own delays are lower than the specified packet
           % delays 
           % OPTIMIZATION, put this in the DELAY LOG LOOP
           useful_mask = ( current_time - data(nodeIndex).data(:,time_step) ) < packet_delays;
           useful_packet_periods = useful_mask .* packet_periods;
    %        
    %        %DEBUG
    %        if nodeIndex == 1 && time_step > 100
    %                 useful_mask
    %                 useful_packet_periods
    %        end
    %        %DEBUG


           % FIND MIN PACKET PERIOD
           min_packet_period = 1000000;
           min_source = 0;
           for source = 1:parameters.NR_NODES
              if useful_mask(source) && packet_periods(source) < min_packet_period
                 min_packet_period = packet_periods(source);
                 min_source = source;
              end 
           end

           if nodeIndex == 1
              %fprintf('TIME: %d NODE: %d MIN_PACKET_PERIOD: %d MIN_SOURCE: %d\n', time_step, nodeIndex, min_packet_period, min_source); 
           end

    %        if data(nodeIndex).synch_counter_max ~= min_packet_period
    %           data(nodeIndex).synch_counter_max = min_packet_period;
    %           if nodeIndex == 1
    %              fprintf('TIME: %d NODE: %d CHANGED_SYNCH_COUNTER_MAX TO: %d\n',time_step,nodeIndex,data(nodeIndex).synch_counter_max); 
    %               
    %           end
    %        end
    %        
    %        if data(nodeIndex).synch_counter > data(nodeIndex).synch_counter_max
    %           data(nodeIndex).synch_counter = data(nodeIndex).synch_counter_max;
    %        end

       end
       
   end
end

   for nodeIndex = 1:parameters.NR_NODES
      
      if data(nodeIndex).synch_counter == 0
         
        destination = links(nodeIndex).links(time_step,randi(links(nodeIndex).link_count(time_step)));
      
        for data_from = 1:parameters.NR_NODES
           % if the destination has older data than the local, transfer it
           if data(destination).data(data_from,time_step + MESSAGE_DELAY) < ...
              data(nodeIndex).data(data_from,time_step)
         
              data(destination).data(data_from,time_step + MESSAGE_DELAY) = ...
              data(nodeIndex).data(data_from,time_step);
              
           end
               
        end
      
      data(nodeIndex).synch_counter = COUNTER;
      else
      data(nodeIndex).synch_counter = data(nodeIndex).synch_counter - 1;
      end
      
   end
  
   
   
   for nodeIndex = 1:parameters.NR_NODES
      
      % Remember old information 
      if data(nodeIndex).data(:,time_step + 1) == no_new_data

         data(nodeIndex).data(:,time_step + 1) = data(nodeIndex).data(:,time_step);
         
      else
         for source = 1:parameters.NR_NODES
            if data(nodeIndex).data(source,time_step + 1) == -1 || ...
               data(nodeIndex).data(source,time_step + 1) < data(nodeIndex).data(source,time_step)
           
               data(nodeIndex).data(source,time_step + 1) = data(nodeIndex).data(source,time_step);
               
            end
         end
      end
      
      % Put timestamp for own time series last_synch
      data(nodeIndex).data(nodeIndex,time_step + 1) = time_step + 1;
     
   end
   
   %pick a random link
        % send own timestamp to next time_step for ORIGINAL
        % forward any information to the next step
        
        
    
    
end


end

function [new_counter] = increment_cyclical_counter(counter,limit)
    new_counter = counter + 1;
    if new_counter > limit
       new_counter = 1;
    end
end

function [answer] = new_messages(current,previous,nodeIndex,nrNodes)
 for i = 1:nrNodes
     if nodeIndex ~= i
        if current(i) ~= previous(i)
           answer = 1;
           return;
        end
     end
 end
 answer = 0;
end

