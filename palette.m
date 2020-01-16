function palette_out = palette(color, varargin)

palettes.reds = [
        1.0000    0.7294    0.7294
    %1.0000    0.4824    0.4824
    1.0000    0.3216    0.3216
    %1.0000         0         0
    0.6549         0         0
    ];
    
palettes.bluegreens = [
    0.0039    0.1216    0.2941
    %0.0118    0.2235    0.4235
         0    0.3569    0.5882
    %0.3922    0.5922    0.6941
    0.7020    0.8039    0.8784];
palettes.greens = [
    0    0.5882    0.4333
    %0.2078    0.6549    0.6118
    0.3294    0.6980    0.6627
    %0.3961    0.7647    0.7294
    0.5137    0.8157    0.7882];
palettes.grays = [    
    0.4353    0.4863    0.5216
    0.4588    0.5137    0.5529
    0.4941    0.5529    0.5961
    0.5216    0.5843    0.6314
    0.5490    0.6157    0.6627
    0 0 0];
palettes.tans = [
    0.5529    0.3333    0.1412
    0.7765    0.5255    0.2588
    0.8784    0.6745    0.4118
    0.9451    0.7608    0.4902
    1.0000    0.8588    0.6745
    1           0.9     0.8
    ];
palettes.blues = [
    0.1314    0.3902    0.8471
    %0.2902    0.5686    0.9490
    0.3922    0.6314    0.9569
    %0.5529    0.7412    1.0000
    0.7490    0.8392    0.9647
    ];

if isfield(palettes,color)
    palette_out = palettes.(color);
else if isfield(palette,color)
    palette_out = palette.(color);
end
end

if nargin>1
   Ncolors = size( palette_out, 1 );
   figure;
   rowfun( @(x,c) line( [0,1],[x,x],'color',c,'linewidth',10 ), table( [1:Ncolors]', palette_out ) );
end
    
end

