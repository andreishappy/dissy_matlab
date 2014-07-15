function [ output ] = find_feedback_line( delays, percentage_below )
%FIND_FEEDBACK_LINE: FINDS THE Y VALUE OF THE LINE UNDER WHICH
% percentage_below PERCENT OF THE DATA POINTS LIE

number_under = 0;
for value = min(delays):0.1:100
    for i = 1:length(delays)
        if delays(i) < value
           number_under = number_under + 1;
        end
    end
    
    if number_under / length(delays) >= (percentage_below / 100)
       output = value;
       return
    end
    
    number_under = 0;
end



end

