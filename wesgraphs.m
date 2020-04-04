y = wes_table.tracksProximityTable;
y = y( y.Track1~=y.Track2 , : );
size(y)

Track1_Idx = y.Track1;
Track2_Idx = y.Track2;
timeDiff = y.timeDiff;

A = zeros( max(Track1_Idx), max(Track2_Idx) );

for i = 1:numel(Track1_Idx)
    
    A( Track1_Idx(i), Track2_Idx(i) ) =  timeDiff( i );
    
end

t = A;
G = digraph(t~=0)
figure; plot(G)