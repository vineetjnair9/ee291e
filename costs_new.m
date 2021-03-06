function costs(evarray);
% Cost functions
% Assume all cars driving at a constant velocity throughout
% Program focuses only on routing them and scheduling charges
v = 45; % mi/h

%% Cost to customers (time)
Cost = C_driving + C_waiting + C_charging;

%Cost = 0;

% Finding number of cars along each edge for graph 
% Still need a 3D matrix or cell array (better)
edgeCount = zeros(V, V, N/Ts); % prediction horizon N and sampling time Ts
% Increment edge count(i,j,k) whenever epsilon E(k,c,ij) == 1 

% Also need nodeCount to keep track of # of cars charging at each node at any given
% time for calc. util %
nodeCount = zeros(V,N/Ts);
% Sum up over binary y's to compute this?

for k = 1:N/Ts % all times
    for i = 1:C % cars
        for j = 1:V % nodes/vertices
          for m = 1:V
              if (m) is 1 of neighbors of (j
            edgeCount(k,i,j)

%% Driving time for all cars for whole journey from start to dest

free_flow_speeds = edgeWeights./v; % where edgeWeights is a VxV matrix 
% set element to 0 if those nodes aren't connected/neighbours
capacity(E); % max. # of cars per edge/highway (just number all of them consecutively)
% calculate index like hashcode - some fn mapping i,j (nodeFrom, nodeTo) to
% a unique index?

% Driving time for car c, between nodes i to j at time k
cost_driving(c,k) = free_flow_speeds(i,j)*(1+(0.15)*(edgeCount(k,i,j)/capacity(hashCode(i,j))));
% sum over all times
% will probably be incorporated into delta_k of the new approach (rate at
% which the car traverses an edge) in new approach

%% Charging times
% t_charging already encoded into the P_charge function
% Then our program/binary decision variables already calculate time spent
% charging for us (depending on change in value of y and gamma)

%% Waiting time (???)
% Need to figure out how to do this, if at all
% Implement queues
% Or just look at change in value of y & gamma (like above)

%% Cost to stations
% Penalizes either over (congestion/long wait) or undertilization of
% charging centers (in terms of no. of cars present there) to ensure optimal allocation
station_capacity = 20;
penalty = 10; % flat penalty cost charged
station_cost = 0;

% function util(v, k) % % utilization of station node v at time k
%     util = 0;
%     for i = 1:
%     return  
% end

% Under or over 50%?
for i = 1:V
    for j = 1:N/Ts % # of charging stations/nodes
        station_cost = station_cost + penalty*abs(sgn((nodeCount(i,j)/station_capacity)-0.5));
    end
end
%%