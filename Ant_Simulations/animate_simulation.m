function [ ] = animate_simulation(s_input, s_mobility, link_output, data, threshold) %output is link_output of get_links
%ANIMATE_SIMULATION Summary of this function goes here
%   Detailed explanation goes here
    v_t = 0:s_input.TIME_STEP:s_input.SIMULATION_TIME;


    figure;
    hold on;
    text_handles = zeros(1,s_mobility.NB_NODES);
    for nodeIndex = 1:s_mobility.NB_NODES-2
        vh_node_pos(nodeIndex) = plot(link_output(nodeIndex).v_x(1),link_output(nodeIndex).v_y(1),'*','color',[0 0 1]);
        text_handles(nodeIndex) = text(link_output(nodeIndex).v_x(1) ,link_output(nodeIndex).v_y(1),num2str(nodeIndex));
    end
    
    vh_node_pos(s_mobility.NB_NODES - 1) = plot(link_output(s_mobility.NB_NODES - 1).v_x(1),link_output(s_mobility.NB_NODES - 1).v_y(1),'*','color',[1 0 0]);
    text_handles(s_mobility.NB_NODES - 1) = text(link_output(s_mobility.NB_NODES - 1).v_x(1) ,link_output(s_mobility.NB_NODES - 1).v_y(1),num2str(s_mobility.NB_NODES - 1));
    vh_node_pos(s_mobility.NB_NODES) = plot(link_output(s_mobility.NB_NODES).v_x(1),link_output(s_mobility.NB_NODES).v_y(1),'*','color',[1 0 0]);
    text_handles(s_mobility.NB_NODES) = text(link_output(s_mobility.NB_NODES).v_x(1) ,link_output(s_mobility.NB_NODES).v_y(1),num2str(s_mobility.NB_NODES));    
    
    
    
    title(cat(2,'Simulation time (sec): ',num2str(s_mobility.SIMULATION_TIME)));
    xlabel('X (meters)');
    ylabel('Y (meters)');
    title('Radom Waypoint mobility');
    ht = text(min(link_output(1).v_x),max(link_output(1).v_y),cat(2,'Time (sec) = 0'));
    %axis([min(link_output(1).v_x) max(link_output(1).v_x) min(link_output(1).v_y) max(link_output(1).v_y)]);
    axis([s_input.V_POSITION_X_INTERVAL(1) s_input.V_POSITION_X_INTERVAL(2) s_input.V_POSITION_Y_INTERVAL(1) s_input.V_POSITION_Y_INTERVAL(2)])
    hold off;
    for timeIndex = 1:length(v_t)-1;
        t = v_t(timeIndex);
        set(ht,'String',cat(2,'Time (sec) = ',num2str(t,4)));
        for nodeIndex = 1:s_mobility.NB_NODES
            set(vh_node_pos(nodeIndex),'XData',link_output(nodeIndex).v_x(timeIndex),'YData',link_output(nodeIndex).v_y(timeIndex));
            if data(nodeIndex).usefulness(timeIndex) > threshold || data(nodeIndex).usefulness(timeIndex) == 0
               set(vh_node_pos(nodeIndex),'Color',[0 0 1]);
            else
               set(vh_node_pos(nodeIndex),'Color',[0 1 0]);
            end
            
            set(vh_node_pos(s_mobility.NB_NODES - 1),'Color',[1 0 0]);
            set(vh_node_pos(s_mobility.NB_NODES),'Color',[1 0 0]);
            
            set(text_handles(nodeIndex),'Position',[link_output(nodeIndex).v_x(timeIndex),link_output(nodeIndex).v_y(timeIndex),0]);
        end
        drawnow;
    end

end

