function [ ] = graph_delay_over_time_multiple( parameters, data, destinations, sources )

assert(length(destinations) == length(sources), 'Destinations and sources lengths have to be the same');
assert(length(destinations) <= 4, 'Function only built for displaying 4 graphs');


current_time = 1:parameters.NR_TIME_STEPS;
current_time_seconds = current_time * parameters.TIME_STEP;

for i = 1:length(destinations)
   consumer = destinations(i);
   producer = sources(i);
   
   actual_time = data(consumer).data(producer,:);
   delay = (current_time - actual_time) * parameters.TIME_STEP;
   
   subplot(2,2,i);
   plot(current_time_seconds,delay);
   set(gca,'XTick',0:20:current_time(end))
   grid on;
   title(sprintf('Delays %d -> %d',producer,consumer));
   
end


end

