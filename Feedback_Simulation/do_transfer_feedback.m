
function [ data ] = do_transfer_feedback( parameters, links )

MESSAGE_DELAY_SECONDS = .05;
MESSAGE_DELAY = MESSAGE_DELAY_SECONDS / parameters.TIME_STEP;
assert(mod(MESSAGE_DELAY,1) == 0, 'MESSAGE_DELAY is not a whole number');

SYNCH_FREQUENCY = 4;%s
COUNTER = SYNCH_FREQUENCY/parameters.TIME_STEP;%time_steps
%Check that the counter is a whole number
assert(mod(COUNTER,1) == 0, 'Sych Counter is not a whole number');





% RUNNING_AVERAGE_FREQUENCY = 5;%s
% RUNNING_AVERAGE_COUNTER = RUNNING_AVERAGE_FREQUENCY / parameters.TIME_STEP;%time steps
% assert(mod(RUNNING_AVERAGE_COUNTER,1) == 0, 'Running Average Counter is not a whole number');

WARMUP_TIME = 100;%s
WARMUP_DONE = WARMUP_TIME / parameters.TIME_STEP;%time periods
assert(mod(WARMUP_DONE,1) == 0, 'WARUMUP_DONE is not a whole number');

% USED TO CALCULATE RUNNING AVERAGES AT EVERY TIME STEP
% UNNECESSARY FOR ALGORITHM AS THEY CAN BE CALCULATED ON THE SPOT

% NR_RUNNING_AVERAGES = parameters.NR_TIME_STEPS - WARMUP_DONE;
% assert(mod(NR_RUNNING_AVERAGES,1) == 0, 'NR_RUNNING_AVERAGES is not a whole number');

FEEDBACK_FREQUENCY = 10;%s
FEEDBACK_COUNTER = FEEDBACK_FREQUENCY / parameters.TIME_STEP;%time steps
assert(mod(FEEDBACK_COUNTER,1) == 0, 'Feedback Counter is not a whole number');
NR_FEEDBACK_DECISION_LINES = ceil(parameters.NR_TIME_STEPS / FEEDBACK_COUNTER) - WARMUP_DONE;


TIME_PER_FEEDBACK_DECISION = 10;%s
FEEDBACK_DECISION_LINE_BUFFER_SIZE = TIME_PER_FEEDBACK_DECISION / parameters.TIME_STEP;

all_nodes = 1:parameters.NR_NODES;


data = repmat(struct,1,parameters.NR_NODES);

for nodeIndex = all_nodes 
%  All entries are initialized to -1
%  -1 => nothing heard from that time series
   data(nodeIndex).data = zeros(parameters.NR_NODES,parameters.NR_TIME_STEPS);
   
   data(nodeIndex).synch_counter_max = COUNTER;
   data(nodeIndex).synch_counter = COUNTER; %randi(data(nodeIndex).synch_counter_max);
   
   
   
   data(nodeIndex).feedback_counter = FEEDBACK_COUNTER;
   data(nodeIndex).delays = zeros(parameters.NR_NODES,FEEDBACK_DECISION_LINE_BUFFER_SIZE);
   data(nodeIndex).delays_counter = 1;
%  USED TO CALCULATE RUNNING AVERAGES AT EVERY TIME STEP
%  UNNECESSARY FOR ALGORITHM AS THEY CAN BE CALCULATED ON THE SPOT
%    data(nodeIndex).running_average_counter = 1;
%    data(nodeIndex).running_averages = zeros(NR_RUNNING_AVERAGES,parameters.NR_NODES);

   data(nodeIndex).feedback_decision_lines = zeros(NR_FEEDBACK_DECISION_LINES, parameters.NR_NODES);
   data(nodeIndex).feedback_decision_lines_counter = 1;
   data(nodeIndex).requirements = repmat(0,parameters.NR_NODES,1);
   data(nodeIndex).up_values = repmat(1000,parameters.NR_NODES,1);
   data(nodeIndex).down_values = repmat(0,parameters.NR_NODES,1);
   data(nodeIndex).max_delay = repmat(0,parameters.NR_NODES,1);
   
   %USED FOR CHANGING PERIOD ACCORDING TO PACKET PERIOD AND DELAY
   data(nodeIndex).packet_period = repmat(COUNTER,parameters.NR_TIME_STEPS,1);
   data(nodeIndex).packet_delay = repmat(10000,parameters.NR_TIME_STEPS,1);
   data(nodeIndex).previous_packet_synched = repmat(-1,parameters.NR_NODES,1);
   data(nodeIndex).delay_table = zeros(parameters.NR_NODES,parameters.NR_TIME_STEPS);
   data(nodeIndex).period_table = repmat(10000,parameters.NR_NODES,parameters.NR_TIME_STEPS);
   
   data(nodeIndex).feedback_received = zeros([parameters.NR_NODES,3,parameters.NR_TIME_STEPS]);


   %USED FOR DEBUGGING
   data(nodeIndex).all_delays = zeros(parameters.NR_NODES,parameters.NR_TIME_STEPS);
   data(nodeIndex).periods = zeros(parameters.NR_TIME_STEPS,1);
end

   useful_mask = zeros(parameters.NR_NODES,1);
   node_indices = [all_nodes]';
   packet_delays = zeros(parameters.NR_NODES,1);
   packet_periods = zeros(parameters.NR_NODES,1);
   useful_packet_periods = zeros(parameters.NR_NODES,1);
   min_packet_period = -1;
    
   no_new_data = repmat(0,parameters.NR_NODES,1);
   

   UP = 1;
   DOWN = -1;
   UP_RESPONSIVENESS = 0.8;
   DOWN_RESPONSIVENESS = 1.05;
   
%     %TAKING OVER EXPERIMENT
%     data(15).requirements(36) = 100;
%     data(15).up_values(36) = 20;
%     data(15).down_values(36) = 10;
%     data(15).max_delay(36) = 25;
%     
%     data(1).requirements(36) = 100;
%     data(1).up_values(36) = 20;
%     data(1).down_values(36) = 10;
%     data(1).max_delay(36) = 25;
%     
%     data(13).requirements(18) = 100;
%     data(13).up_values(18) = 10;
%     data(13).down_values(18) = 2;
%     data(13).max_delay(18) = 14;
    
    data(2).requirements(4) = 100;
    data(2).up_values(4) = 2;
    data(2).down_values(4) = 0.3;
    data(2).max_delay(4) = 3;

    data(26).requirements(28) = 100;
    data(26).up_values(28) = 2;
    data(26).down_values(28) = 0.3;
    data(26).max_delay(28) = 3;


% Initialize own time series
for nodeIndex = all_nodes
   data(nodeIndex).data(nodeIndex,1) = 1; 
end

for time_step = 1:parameters.NR_TIME_STEPS-MESSAGE_DELAY
    
   % DELAY LOG AND CONSUMER FEEDBACK LOOP 
   for nodeIndex = all_nodes
      %log value to be used for average
      current_time = repmat(time_step,parameters.NR_NODES,1);
      
      data(nodeIndex).delays(:,data(nodeIndex).delays_counter) = (current_time - data(nodeIndex).data(:,time_step)) * parameters.TIME_STEP;
      data(nodeIndex).delays_counter = increment_cyclical_counter(data(nodeIndex).delays_counter,FEEDBACK_DECISION_LINE_BUFFER_SIZE);
      
      %USED FOR DEBUG
      data(nodeIndex).all_delays(:,time_step) = (current_time - data(nodeIndex).data(:,time_step)) * parameters.TIME_STEP;
      
      
      %TO DELETE OR CHANGE FOR ACTUAL FEEDBACK
      if time_step > WARMUP_DONE 
         %calculate running average at every time step
%          data(nodeIndex).running_averages(data(nodeIndex).running_average_counter,:) = mean(data(nodeIndex).delays,2);
         
         if data(nodeIndex).feedback_counter == 0 
            data(nodeIndex).feedback_decision_lines( data(nodeIndex).feedback_decision_lines_counter, :) = find_decision_lines(nodeIndex, data(nodeIndex).delays, data(nodeIndex).requirements);
            if ismember(nodeIndex, [15,22])
               fprintf('TIME: %d NODE: %d DECISION LINE 36: %.10f\n',time_step,nodeIndex,data(nodeIndex).feedback_decision_lines(data(nodeIndex).feedback_decision_lines_counter,36));
            end

%             DO THE FEEDBACK
            for source = all_nodes
                if data(nodeIndex).requirements(source) ~= 0
                
                    if data(nodeIndex).feedback_decision_lines(data(nodeIndex).feedback_decision_lines_counter, source) > data(nodeIndex).up_values(source)
                       %size(data(source).feedback_received(nodeIndex, :, time_step + 1))
                       %fprintf('TIME: %d NODE: %d LAST SYNCHED %d -> %d',time_step, nodeIndex, source, data(nodeIndex).data(source,time_step))
                       pack_period = data(source).packet_period(data(nodeIndex).data(source,time_step));
                       fprintf('TIME: %d NODE: %d\n',time_step,nodeIndex);
                       fprintf('     UP FEEDBACK SENT: [%d, %d, 1]\n\n',data(nodeIndex).max_delay(source),pack_period); 
                       data(source).feedback_received(nodeIndex, :, time_step + 1) = [data(nodeIndex).max_delay(source), data(source).packet_period(data(nodeIndex).data(source,time_step)), 1];
                    end
                    
                    if data(nodeIndex).feedback_decision_lines(data(nodeIndex).feedback_decision_lines_counter, source) < data(nodeIndex).up_values(source)
                       %size(data(source).feedback_received(nodeIndex, :, time_step + 1))
                       %fprintf('TIME: %d NODE: %d LAST SYNCHED %d -> %d',time_step, nodeIndex, source, data(nodeIndex).data(source,time_step))
                       pack_period = data(source).packet_period(data(nodeIndex).data(source,time_step));
                       fprintf('TIME: %d NODE: %d\n',time_step,nodeIndex);
                       fprintf('     DOWN FEEDBACK SENT: [%d, %d, -1]\n\n',data(nodeIndex).max_delay(source),pack_period); 
                       data(source).feedback_received(nodeIndex, :, time_step + 1) = [data(nodeIndex).max_delay(source) , data(source).packet_period(data(nodeIndex).data(source,time_step)), -1];
                    end
                   
                
                
                end
            end
            
            
            data(nodeIndex).feedback_counter = FEEDBACK_COUNTER;
            data(nodeIndex).feedback_decision_lines_counter = data(nodeIndex).feedback_decision_lines_counter + 1;
         else
            data(nodeIndex).feedback_counter = data(nodeIndex).feedback_counter -1;
         end
      end
   end
   
   %Change period_delay table according to feedback received 
   for nodeIndex = all_nodes
%          %debugging period_table changing
%          data(36).period_table(1,400) = 100;
%          data(36).period_table(2,400) = 20;
%          data(36).period_table(3,400) = 10; 
        
        %propagate delay_period_table to the next time_step
        data(nodeIndex).delay_table(:,time_step + 1) = data(nodeIndex).delay_table(:,time_step);
        data(nodeIndex).period_table(:,time_step + 1) = data(nodeIndex).period_table(:,time_step);          
         
        %Change local delay_period_table
        if not(empty(data(nodeIndex).feedback_received(:,:,time_step)))
           fprintf('TIME: %d NODE: %d NOT EMPTY FEEDBACK_RECEIVED\n',time_step,nodeIndex);
           for source = all_nodes
              feedback_signal = data(nodeIndex).feedback_received(source,:,time_step);
              %Check that the feedback is not empty
              if not(empty(feedback_signal))
                 %If this is the first ever requirement heard
                 if empty(data(nodeIndex).delay_table(:,time_step)) && ...
                    allequal(data(nodeIndex).period_table(:,time_step),10000)
                    fprintf('TIME: %d NODE: %d THE DELAY AND PERIOD TABLES WERE EMPTY\n',time_step,nodeIndex)
                    data(nodeIndex).delay_table(source,time_step + 1) = feedback_signal(1);
                    if feedback_signal == UP
                        data(nodeIndex).period_table(source,time_step + 1) = floor(DOWN_RESPONSIVENESS * COUNTER);
                    elseif feedback_signal == DOWN
                        data(nodeIndex).period_table(source,time_step + 1) = floor(UP_RESPONSIVENESS * COUNTER);                        
                    end
                    
                 %Some other requirements exist in the table already
                 else
                    if feedback_signal(3) == UP
                       data(nodeIndex).period_table(source,time_step + 1) = floor(UP_RESPONSIVENESS * feedback_signal(2));
                       
                       fprintf('UP TIME: %d NODE: %d CHANGED PERIOD FOR CONSUMER %d\n   %d -> %d\n',...
                           time_step + 1, nodeIndex, source, data(nodeIndex).period_table(source,time_step) * parameters.TIME_STEP, data(nodeIndex).period_table(source,time_step + 1) * parameters.TIME_STEP)
                       
                    elseif feedback_signal(3) == DOWN
                       % ONLY TAKE INTO ACCOUNT TO DOWNS IF THIS IS THE HARDEST REQUIREMENT
                       if data(nodeIndex).period_table(source,time_step) <= min(data(nodeIndex).period_table(:,time_step))
                          data(nodeIndex).period_table(source,time_step + 1) = floor(DOWN_RESPONSIVENESS * data(nodeIndex).period_table(source,time_step));
                       end
                       
                       fprintf('DOWN TIME: %d NODE: %d CHANGED PERIOD FOR CONSUMER %d\n   %d -> %d\n',...
                           time_step + 1, nodeIndex, source, data(nodeIndex).period_table(source,time_step), data(nodeIndex).period_table(source,time_step + 1))
                       
                    end
                 end
                 %update the max delay with the one in the feedback message
                 data(nodeIndex).delay_table(source,time_step + 1) = feedback_signal(1);
              end
           end
           
        end
        
        
        
   end
   
%  Change packet periods according to delay_period_table
%  if they are empty we just leave them at the default values
%  COUNTER and 10000
   for nodeIndex = all_nodes
        
        %Change packet periods according to delay_period_table
        % if they are empty we just leave them at the default value
        if not(empty(data(nodeIndex).delay_table(:,time_step))) && ...
           not(allequal(data(nodeIndex).period_table(:,time_step),10000))
           
           % DEBUG
           % print_delay_period_table(data(nodeIndex).delay_table(:,time_step),data(nodeIndex).period_table(:,time_step),time_step,nodeIndex);

           data(nodeIndex).packet_period(time_step) = min(data(nodeIndex).period_table(:,time_step));
           data(nodeIndex).packet_delay(time_step) = max(data(nodeIndex).delay_table(:,time_step));
           if data(nodeIndex).packet_period(time_step -1) ~= data(nodeIndex).packet_period(time_step)
             %DEBUG
%            fprintf('TIME: %d NODE: %d \n   PACKET_PERIOD %d -> %d\n   PACKET_DELAY %d -> %d\n',...
%                time_step, nodeIndex, data(nodeIndex).packet_period(time_step - 1), data(nodeIndex).packet_period(time_step), ...
%                data(nodeIndex).packet_delay(time_step -1), data(nodeIndex).packet_delay(time_step));
           end
        else
           data(nodeIndex).packet_period(time_step) = COUNTER;
           data(nodeIndex).packet_delay(time_step) = 10000;
        end

   end

% Change own period according to packet periods 
  for nodeIndex = all_nodes
      
     % if no requirements present, gossip at default
     if no_requirements_present(data, nodeIndex, time_step)
        data(nodeIndex).periods(time_step + 1) = COUNTER;
        if data(nodeIndex).synch_counter_max ~= COUNTER
           fprintf('TIME: %d NODE: %d Changed period back to DEFAULT',time_step,nodeIndex);
           data(nodeIndex).synch_counter = max([0,COUNTER - (data(nodeIndex).synch_counter_max - data(nodeIndex).synch_counter)]);
           data(nodeIndex).synch_counter_max = COUNTER;
        end
     else
        
        min_period = 10000;
        applied_source = 0;
        latest_timestamps_synched = data(nodeIndex).data(:,time_step);
        for source = all_nodes
            if data(nodeIndex).all_delays(source,time_step) < data(source).packet_delay(time_step)

                if latest_timestamps_synched(source) ~= 0 && ...
                   data(source).packet_delay(latest_timestamps_synched(source)) ~= 10000
               
                   if min_period > data(source).packet_period(latest_timestamps_synched(source))
                   min_period = data(source).packet_period(latest_timestamps_synched(source));
                   applied_source = source;
                   end
                end
                
            end
        end
        
        if min_period == 10000
           old_counter = data(nodeIndex).synch_counter;
           data(nodeIndex).synch_counter = max([0,COUNTER - (data(nodeIndex).synch_counter_max - data(nodeIndex).synch_counter)]);
           data(nodeIndex).periods(time_step + 1) = COUNTER;
           data(nodeIndex).synch_counter_max = COUNTER; 
           if ismember(nodeIndex,[15,22,36]) && time_step > 1 && ...
              data(nodeIndex).periods(time_step) ~= COUNTER
              fprintf('TIME: %d NODE: %d NO REQUIREMENTS APPLIED\n',time_step,nodeIndex);
              fprintf('                    Period  %d -> %d\n',data(nodeIndex).periods(time_step) * parameters.TIME_STEP, data(nodeIndex).periods(time_step + 1)* parameters.TIME_STEP);
              fprintf('                    Counter %d -> %d\n\n',old_counter,data(nodeIndex).synch_counter);
           end
        
        
        else
        
           if nodeIndex == 15
%               fprintf('TIME %d NODE: %d Applied period: %d from source: %d last_synched %d delay: %ds\n',...
%                       time_step, nodeIndex, min_period, applied_source,
%                       latest_timestamps_synched(applied_source), data(applied_source).packet_delay(latest_timestamps_synched(applied_source)));
           end
           
           data(nodeIndex).periods(time_step + 1) = min_period;
           old_counter = data(nodeIndex).synch_counter;
           data(nodeIndex).synch_counter = max([0,min_period - (data(nodeIndex).synch_counter_max - data(nodeIndex).synch_counter)]);
           data(nodeIndex).synch_counter_max = min_period; 
          
           if ismember(nodeIndex,[15,22,36]) && data(nodeIndex).periods(time_step) ~= data(nodeIndex).periods(time_step + 1)
              fprintf('TIME: %d NODE: %d APPLIED REQUIREMENT FROM: %d\n', time_step, nodeIndex, applied_source)
              fprintf('                    Period  %d -> %d\n', data(nodeIndex).periods(time_step)* parameters.TIME_STEP , data(nodeIndex).periods(time_step + 1)* parameters.TIME_STEP);
              fprintf('                    Counter %d -> %d\n\n', old_counter,data(nodeIndex).synch_counter);
           end
           
        end
        

        
        
        
     % else
     %   find for which time series the own_delay < packet_delay
     
     %   for those time series find the largest period
   
     %   change the synch_max and the counter accordingly
     end
  end
   
  
  %TRANSFER DATA
  for nodeIndex = all_nodes
      if nodeIndex == 15 && data(nodeIndex).synch_counter > data(nodeIndex).synch_counter_max
         fprintf('ALEEEERT! TIME: %d NODE: %d Period: %d Counter: %d\n', time_step, nodeIndex, data(nodeIndex).synch_counter_max, data(nodeIndex).synch_counter);
      end
      if data(nodeIndex).synch_counter == 0
         
        destination = links(nodeIndex).links(time_step,randi(links(nodeIndex).link_count(time_step)));
      
        for data_from = all_nodes
           % if the destination has older data than the local, transfer it
           if data(destination).data(data_from,time_step + MESSAGE_DELAY) < ...
              data(nodeIndex).data(data_from,time_step)
         
              data(destination).data(data_from,time_step + MESSAGE_DELAY) = ...
              data(nodeIndex).data(data_from,time_step);
              
           end
               
        end
      
      data(nodeIndex).synch_counter = data(nodeIndex).synch_counter_max;
      else
      data(nodeIndex).synch_counter = data(nodeIndex).synch_counter - 1;
      end
      
   end
  
   
  %REMEMBER DATA 
  for nodeIndex = all_nodes
      
      % Remember old information 
      if data(nodeIndex).data(:,time_step + 1) == no_new_data

         data(nodeIndex).data(:,time_step + 1) = data(nodeIndex).data(:,time_step);
         
      else
         for source = all_nodes
            if data(nodeIndex).data(source,time_step + 1) == -1 || ...
               data(nodeIndex).data(source,time_step + 1) < data(nodeIndex).data(source,time_step)
           
               data(nodeIndex).data(source,time_step + 1) = data(nodeIndex).data(source,time_step);
               
            end
         end
      end
      
      % Put timestamp for own time series last_synch
      data(nodeIndex).data(nodeIndex,time_step + 1) = time_step + 1;
     
   end        
    
    
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

function [answer] = empty (matrix)
    for i = 1:length(matrix)
       if matrix(i) ~= 0
          answer = 0;
          return
       end
    end
    answer = 1;
end

function [answer] = allequal (matrix, value)
    for i = 1:length(matrix)
       if matrix(i) ~= value
          answer = 0;
          return
       end
    end
    answer = 1; 
end

function [] = print_delay_period_table(delay_table,period_table,time_step,node_index)
    fprintf('DELAY-PERIOD TABLE NODE: %d TIME: %d\n',node_index,time_step)
    for consumer = 1:length(delay_table)
       if delay_table(consumer) ~= 0
       fprintf('   | %d | %d | %d |\n',consumer,delay_table(consumer),period_table(consumer));
       end
    end
end

function [answer] = no_requirements_present(data, nodeIndex, time_step)
   answer = 1;
   latest_packet_timestamps = data(nodeIndex).data(:,time_step);
   
   for i = 1:length(latest_packet_timestamps)
    if latest_packet_timestamps(i) ~= 0 && data(i).packet_delay(time_step) ~= 10000
%         fprintf('NODE: %d TIME: %d I: %d compared %d AND %d\n', nodeIndex, time_step, i, data(i).packet_delay(time_step), 10000);
        answer = 0;
    end
   end
   
end