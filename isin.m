function varargout = isin(A,B)
% Check for whether the element A is in B
%
% (Can also handle accidental uses in the opposite order
% provided that one of the inputs is a single string, integer, double)
    if nargin==1;
        fprintf('Please provide two inputs to the function:\n\ne.g. isin(1,[1,2,3])\n');
        return
    end
    
    % Checking for string cells
    if and( iscell(A), isstr(B) )
       varargout{1} = logical(cell2mat(strfind(A,B)));
       if isempty(varargout{1}); varargout{1} = logical(0); end
    end
    
    if and( isstr(A), iscell(B) )
       varargout{1} = logical(cell2mat(strfind(B,A)));
       if isempty(varargout{1}); varargout{1} = logical(0); end
    end
    % End string cell handling
    
    
    if and( isa(A,'double'), isa(B,'double') )
        if numel(A)>numel(B) % A is the array
            varargout{1} = logical(isempty( setdiff( B, A ) )); % Empty means it is in
        end
        
        if numel(B)>numel(A) % B is the array
            varargout{1} = logical(isempty( setdiff( A, B ) ));
        end
    end

end