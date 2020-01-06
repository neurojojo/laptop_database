function output = vsum( varargin )

    % Equal sized arrays get summed
    %
    % Orient the input so that it can be summed over the rows
    if eq(1,size( varargin{1}, 1 ))
        tosum = cellfun(@(x) x', varargin, 'UniformOutput', false);
        output = sum( cell2mat( tosum ), 1 ); % Keep orientation of inputs
    else 
        output = sum( cell2mat( varargin ), 2 );
    end
    

end
