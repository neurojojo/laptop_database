classdef crossObj < handle
    
    properties
        label
        x0
        x1
        xcenter
        y0
        y1
        ycenter
        color
        parent
    end
    
    methods
        function obj = crossObj( label, x0, xcenter, x1, y0, ycenter, y1, color, maxColor, parent, legend )
            
            % Only plot non-NaN entries
            if eq( sum(isnan([x0,xcenter,x1,y0,ycenter,y1])), 0 ) & ((x1-x0)>0 & (y1-y0)>0)
                
                mypalette = [0    0.4470    0.7410;0.8500    0.3250    0.0980;0.9290    0.6940    0.1250;0.4940    0.1840    0.5560;0.4660    0.6740    0.1880;0.3010    0.7450    0.9330;    0.6350    0.0780    0.1840;     0    0.4470    0.7410; 0.8500    0.3250    0.0980; 0.9290    0.6940    0.1250];
                colors = mypalette;
                
                line( [x0,x1], [ycenter, ycenter], 'color', colors(color,:), 'parent', parent, 'linewidth', 4 );
                line( [xcenter,xcenter], [y0, y1], 'color', colors(color,:), 'parent', parent, 'linewidth', 4 );
                
                text( x0, y1, legend, 'color', colors(color,:), 'parent', parent );
                [obj.label,obj.x0,obj.x1,obj.xcenter,obj.y0,obj.y1,obj.ycenter,obj.parent] = deal (label,x0,x1,xcenter,y0,y1,ycenter,parent);
            end
            
        end
    end
end