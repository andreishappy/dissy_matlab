function [ ] = graph_error_bars( )
x = [1,2,3];
y = [1,4,9];
error = [1,2,3];
plot(x,y)
errorbar(x,y,error)

end

