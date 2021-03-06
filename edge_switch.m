% This builds the edge switching constraints
function con = edge_switch(xhi,gam,max_edge,next_edge,current_edge,n_nodes,E,k)
% xhi_short = @(i,xhi,n) xhi((i-1)*(length(xhi)/n)+1:i*(length(xhi)/n));
con = [];
% This is very inefficient and should be the inner product of the row of E
% and the part of, xhi, xhi_short, which is just the releveant segment
% since xhi is a 1-d vector of length n*n.

for i = 1:n_nodes
    % Consider the cases where a switch must be made due to reaching a node
    % There are n of these cases sicne this can occur at each node in a
    % network.
    idx = n_nodes*(i-1);
    con = [con,...
        (0-max_edge)*(2-xhi(i,k)-gam) <= -next_edge +...
        xhi(idx+1,k+1)*E(i,1) + xhi(idx+2,k+1)*E(i,2) + ...
        xhi(idx+3,k+1)*E(i,3) + xhi(idx+4,k+1)*E(i,4) + xhi(idx+5,k+1)*E(i,5),...
        (0-max_edge)*(2-xhi(i)-gam) <=  next_edge +...
        -(xhi(idx+1,k+1)*E(i,1) + xhi(idx+2,k+1)*E(i,2) + ...
        xhi(idx+3,k+1)*E(i,3) + xhi(idx+4,k+1)*E(i,4) + xhi(idx+5,k+1)*E(i,5)),...
        ];
end
% take care of the case where it's not at a node
con = [con,...
        (0-max_edge)*gam <= -next_edge + current_edge,...
        (0-max_edge)*gam <=  next_edge - current_edge];

end