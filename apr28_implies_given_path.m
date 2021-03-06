% uses the array form of the variables for clarity
%% Define the problem parameters
clear, close all, clc
clear('yalmip');
N = 40; % prediction horizon
Ts = 1; % sample time
C = 2; % number of cars
n_nu = 5; % number of nodes (>= to the # of stations)
capacity_nu = 1*ones(n_nu,1); % vector of vehicle capacity per station
Ec = 5; % Power threshold (switches power to decrementing)
E_max = 15; %kWh (battery capacity)
E_min = 0;
d_max = 100;
Pmax = 45; %kW (max charging power)
P_drive_test = 2; % kW
P_charge_test = 5; % kW
D_test = 5;
car_capacity = 10;
proximity_margin = .95; % the equality constraints never hold exactly
final_margin = .95; % final state won't be exactly the end point due to discrete dynamics
%% Run the feas_traj function to get the sequences (ordered-sets) of edges
% % to traverse
% % Initial nodes (nu)
% 
% % Define connected graph G = (V,E,A) 
% 
% traj = feas_traj(C
% 
% Before developing the above, use a basic problem
traj.num_cars = 2; % scalar indicating the number of cars on the network
traj.edges = {4,3}; % cell array indicating the numbers of edges traversed
traj.max_edges = 4; 
traj.sequence = {[1 3 4 5],[2 4 5]}; % cell array of the node sequence
traj.distances = {[0 25 10 30], [0 15 30]}; % cell array of the edge weights
traj.cum_distances = {[0 25 35 65], [0 15 45]};
n_nodes = 5;
A = [0 1 1 0 0;
     1 0 0 1 0;
     1 0 0 1 1;
     0 1 1 0 1;
     0 0 1 1 0];
E = [0  30 25 0  0;
     0  0  0  15 0;
     0  0  0  10 45;
     0  0  0  0  30;
     0  0  0  0  0];
E = E + E';


m_x = [E_min; -1e-10];
M_x = [E_max; d_max];
M_beta_var = [1 1 1]';
m_leg = -15; % min and max distances for edges
M_leg = 30;
x0 = [E_max; 0];
%% Set up the MIQP problem (YALMIP)

% x{car}(state,k)
x = sdpvar(repmat(2,1,C),repmat(N+1,1,C));
y = binvar(C,N);
gam = binvar(C,N);

% beta_var{car}(mode,k)
beta_var = binvar(repmat(3,1,C),repmat(N+1,1,C));
delta_dist = binvar(C,N);

% define the dynamical constraints
constraints = [];

for k = 1:N
    for c = 1:C
        
        constraints = [constraints,...
            implies(2 == gam(c,k) + y(c,k),...
                    beta_var{c}(1,k)),...
            implies(1 == gam(c,k) + y(c,k),...
                    beta_var{c}(2,k)),...
            implies(0 == gam(c,k),...
                    beta_var{c}(3,k)),...
                    sum(beta_var{c}(:,k)) == 1,...
                    ];
        
        constraints = [constraints,...
            implies(beta_var{c}(1,k),...
                    x{c}(:,k+1) == x{c}(:,k) + [P_charge_test; 0]*Ts),...
            implies(beta_var{c}(2,k),...
                    x{c}(:,k+1) == x{c}(:,k))...
            implies(beta_var{c}(3,k),...
                    x{c}(:,k+1) == x{c}(:,k) + [-P_drive_test; D_test]*Ts),...
                    ];
        
        % add the constraints on gamma (at a node?)
        for j = 2:traj.distances{c}-1
            constraints = [constraints, 
                implies(2-proximity_margin)*traj.distances{c}(j-1)...
                        <= x{c}(2,k) <= ...
                        proximity_margin*traj.distances{c}(j),...
                        ;
            
        end
        
        
        
        % time invariant box constraints on the state
        constraints = [constraints,...
            m_x <= x{c}(:,k+1) <= M_x];
        
    end
end

initial_conditions = [];
terminal_constraints = [];
for c = 1:C
    initial_conditions = [initial_conditions,...
        x{c}(:,1) == x0,...
        m_x <= x{c}(:,1) <= M_x];
    k = N+1;
    terminal_constraints = [terminal_constraints, ...
        beta_var{c}(1,k) + beta_var{c}(2,k) + beta_var{c}(3,k) == 1,...
        x{c}(2,N+1) >= final_margin*traj.cum_distances{c}(end)];
end
constraints = [constraints, ...
    initial_conditions, terminal_constraints];

figure(3); subplot(121);
plot(constraints,x{1}(1,:),[],[],sdpsettings('relax',1));
xlabel('Car #');
ylabel('Time step');
zlabel('Energy');

subplot(122);
plot(constraints,x{1}(2,:),[],[],sdpsettings('relax',1))
xlabel('Car #');
ylabel('Time step');
zlabel('Distance');
options = sdpsettings('verbose',0,'solver','gurobi');
obj = (100-x{1}(2,N+1))^2 +(100-x{2}(2,N+1))^2;
p = optimize(constraints,[],options);
%% Show the results
if p.problem == 1
    p
    error('Infeasible');
elseif p.problem ~= 0
    p
    error('The above went wrong');
else
    p
    states = cell(C,1);
    for k = 1:N+1
        for c = 1:C
            states{c} = [states{c},value(x{c}(:,k))];
        end         
    end
    
    figure(1);  
    for c = 1
        subplot(121);
        plot(states{c}(1,:),'-x'); title('Energy vs time');
        legend(['Car ' num2str(c)]); hold on
        subplot(122); 
        plot(states{c}(2,:),'-x'); title('Distance vs time'); 
        legend(['Car ' num2str(c)]); hold on
    end
    
    
    figure(2); 
    for k = 1:N+1
         if value(beta_var{1}(1,k)) == false
             v_k = 3;
         elseif value(beta_var{1}(2,k)) == false
             v_k = 2;
         else
             v_k = 1;
         end
             
        scatter(k,v_k,'kx'); hold on
        title('State: Car 1'); grid on
        axis([1 N+1 0 3]);
        
        
    end
    legend('3: Charging','2: Waiting','1: Driving');

    disp('Decision-making logic');
    gamma__y = [value(gam(1,:))',value(y(1,:))']
end