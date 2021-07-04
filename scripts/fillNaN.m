% vector_out = fillNan(vector_in, N_ave)
%
% If the vector 'vector_in' has NaN values at the beginning (end),
% the routine fillNaN replaces these with constant values equal to the
% mean of the 'N_ave' first (last) numerical values in the vector.


function outvec = fillNaN(invec,N_ave)


% if there are no NaN values, do nothing
if sum(isnan(invec))==numel(invec)
    outvec = invec;

else
    outvec = invec;
    % fill in the NaN values at start of vector
    if isnan(invec(1))
        where = find(~isnan(invec),1,'first');
        outvec(1:(where-1)) = mean(invec(where:(where+N_ave)));
    end
    % fill in the NaN values at the end of vector
    if isnan(invec(end))
        where = find(~isnan(invec),1,'last');
        outvec((where+1):end) = mean(invec((where-N_ave):where));
    end
end
