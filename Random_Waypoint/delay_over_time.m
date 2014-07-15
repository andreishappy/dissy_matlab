function [ output_args ] = delay_over_time( s_input, data, consumer, producer )

    last_synch = data(consumer).data(:,producer)';
    current_time = 0:length(last_synch)-1;
    size(last_synch)
    size(current_time)
    delay = (current_time - last_synch) * s_input.TIME_STEP;
    
    plot(current_time * s_input.TIME_STEP, delay);
    axis([0,2500,-2,60]);
end

