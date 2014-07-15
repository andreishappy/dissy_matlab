function [ output ] = find_average_delays( s_input, link_output)
%FIND_AVERAGE_DELAYS Summary of this function goes here
%   Detailed explanation goes here
   output = [];
 
   freqs = [2,20,30,40,50,100,200];
   for i = freqs
      s_input.GLOBAL_FREQUENCY = i; 
      data = do_transfer_new(s_input,link_output);
      output = [output,find_average_delay(s_input,link_output,data)];
      disp('one done');
   end
   plot(freqs,output)
   
   
end

