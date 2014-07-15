function [ ] = graph_delay_over_time( parameters, data, destination, source )
%GRAPH_DELAY_OVER_TIME Summary of this function goes here
%   Detailed explanation goes here
    current_time = 1:parameters.NR_TIME_STEPS;
    actual_time = data(destination).data(source,:);
    size(current_time)
    size(actual_time)
    
    delay = current_time - actual_time;
    
    %turn them into s
    current_time = current_time * parameters.TIME_STEP;
    delay = delay * parameters.TIME_STEP;

    min(delay(100:end))
    
    plot(current_time,delay);
    set(gca,'XTick',0:20:current_time(end))
    grid on;
end

