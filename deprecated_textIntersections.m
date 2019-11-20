function mydistance = textIntersections( input_table )

    atable = input_table;

    mydouble = @(x) {double(x{1})};
    mytablearray = table2array( rowfun( mydouble, atable ) );
    
    mydistance = zeros( size(mytablearray,1), size(mytablearray,1) );
    
    for i = 1:size(mytablearray,1)
        for j = 1:size(mytablearray,1)
            mydistance(i,j) = numel( intersect(mytablearray{i},mytablearray{j}) )/min( numel(mytablearray{i}), numel(mytablearray{j}) );
        end
    end
    
end