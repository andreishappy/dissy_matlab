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