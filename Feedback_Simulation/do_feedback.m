function [ control, already_heard, already_heard_counter ] = do_feedback( links, parameters  )
%DO_FEEDBACK Summary of this function goes here
%   Detailed explanation goes here

% Assumptions made in this:
%   - messages have delay of one time_slot
%   - a node does not store a duplicated feedback message
%   - a node does not store a feedback message it has heard in the recent
%     past
%





%indices of feedback messages
COMMAND = 1;
FREQ = 2;
SENDER_ID = 3;
SEQ_NR = 4; 
TIME_SERIES_ID = 5;

ALREADY_HEARD_LENGTH = 20;
already_heard = repmat(zeros(1,2),[20,1,parameters.NR_NODES]);
already_heard_counter = repmat(1,1,parameters.NR_NODES);

feedback_struct = zeros(1,5);

CONTROL_LENGTH = 20;
control = repmat(struct,1,parameters.NR_NODES);
for nodeIndex = 1:parameters.NR_NODES
    control(nodeIndex).control = repmat(feedback_struct, ...
                                        [CONTROL_LENGTH,1,[parameters.NR_TIME_STEPS]]);
    control(nodeIndex).counter = repmat(1,parameters.NR_TIME_STEPS,1);
    control(nodeIndex).seq_nr = 1;
    control(nodeIndex).period_table = zeros(parameters.NR_NODES,1);
end

    DEFAULT_COUNTER = 5;   


disp('entered do_feedback')

for time_step = 1:parameters.NR_TIME_STEPS-1
    
    %ARTIFICIAL FEEDBACK MESSAGE
    for nodeIndex = 1:parameters.NR_NODES
        
       
        %launch one feedback message
        if (nodeIndex == 1 || nodeIndex == 18) && ismember(time_step,1:4);

           %set up the feedback message
           feedback = [1, nodeIndex, nodeIndex, control(nodeIndex).seq_nr,2];

           %increment the sequence number for the next feedback
           control(nodeIndex).seq_nr = control(nodeIndex).seq_nr + 1;

           control(nodeIndex).control(control(nodeIndex).counter(time_step),:,time_step) = feedback;
           control(nodeIndex).counter(time_step) = control(nodeIndex).counter(time_step) + 1;
                    
        end
           
    end
    
    
    % FORWARD FEEDBACKS
    for nodeIndex = 1:parameters.NR_NODES
        for i = 1:control(nodeIndex).counter(time_step) -1
            feedback_message = control(nodeIndex).control(i,:,time_step);
            
            %FORWARD IF NOT ALREADY HEARD OR SENT
            if not(ismember([feedback_message(SENDER_ID), feedback_message(SEQ_NR)],already_heard(:,:,nodeIndex),'rows'))

                for destination_index = 1: links(nodeIndex).link_count(time_step)
                    destination = links(nodeIndex).links(time_step,destination_index);
                    
%                     if ismember(feedback_message, ...
%                                     control(destination).control(:,:,time_step+1),'rows')
%                        fprintf('TIME: %d DIDN''T FORWARD %d -> %d : feedback [SOURCE %d, SEQ %d]\n',...
%                                time_step + 1, nodeIndex, destination, feedback_message(SENDER_ID), feedback_message(SEQ_NR));
%                                 
%                     end
                    
                    if not(ismember(feedback_message, control(destination).control(:,:,time_step+1),'rows')) && ...
                       not(ismember([feedback_message(SENDER_ID), feedback_message(SEQ_NR)],already_heard(:,:,destination),'rows'))
                       control(destination).control(control(destination).counter(time_step+1),:,time_step+1) = feedback_message;
                       control(destination).counter(time_step+1) = control(destination).counter(time_step+1) + 1;
                       assert(control(destination).counter(time_step+1) < CONTROL_LENGTH,'Control buffer OVERFLOW');

                       fprintf('TIME ARRIVED: %d FORWARDED %d -> %d : feedback [SOURCE %d, SEQ %d]\n',...
                               time_step + 1, nodeIndex, destination, feedback_message(SENDER_ID), feedback_message(SEQ_NR));
                    end
                end
                
                
               
            end
            
        end
    end
    
    
    % CHANGE THE LOCAL PERIOD TABLE
    
    
    
    
    
    % ADD ALREADY HEARD CONTROL MESSAGES
    for nodeIndex = 1:parameters.NR_NODES
         
        %IMPORTANT: iterating to -1 because the counter points to the next empty spot
        for i = 1:control(nodeIndex).counter(time_step)-1
           feedback_message = control(nodeIndex).control(i,:,time_step);
              
    
           if not(ismember([feedback_message(SENDER_ID), feedback_message(SEQ_NR)],already_heard(:,:,nodeIndex),'rows'))
               fprintf('TIME: %d NODE: %d ADDED already_heard: feedback [SOURCE %d, SEQ %d]\n',...
                      time_step + 1, nodeIndex, feedback_message(SENDER_ID), feedback_message(SEQ_NR));
                  
                  
               already_heard(already_heard_counter(nodeIndex),:,nodeIndex) = ...
               [feedback_message(SENDER_ID),feedback_message(SEQ_NR)];
           
               %increment counter
               already_heard_counter(nodeIndex) = increment_already_heard_counter(already_heard_counter(nodeIndex),ALREADY_HEARD_LENGTH);
%              fprintf('NODE %d ALREADY_HEARD_COUNTER AT:
%              %d\n',nodeIndex,already_heard_counter(nodeIndex));
           end
            

        end
           
    end
        

    
    
end

end
function [new_count] = increment_already_heard_counter(count,size)
    new_count = count + 1;
    if count > size
       new_count = 1; 
    end
end