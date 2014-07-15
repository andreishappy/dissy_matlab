function [ average_delay ] = calculate_average_delay_one_consumer( parameters, data, destination)
    
    current_time = zeros(parameters.NR_TIME_STEPS,parameters.NR_NODES);

    for i = 1:parameters.NR_TIME_STEPS
        current_time(i,:) = i-1;
    end

    
    delays = current_time - data(destination).data;
    
    averages = mean(delays,1);
    average_delay = mean(averages);
end

