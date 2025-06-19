% IMPLEMENTING PERPETUAL INVENTORY METHOD AND FINDING K0
% Modified date: Jan/18/2023

%% 0. Loading data
clc; 
clearvars;
cd 'C:\Users\edloaeza\Dropbox\SchoolDistrict2022\replication\data';

% Import the data
data1 = readtable("C:\Users\edloaeza\Dropbox\SchoolDistrict2022\replication\data\data.txt");

% Convert to output type
data = table2array(data1);


%% Prepare data
orig_id = data(:,1:2);
T = 40; 

%Creating new time and panel identifiers:
newt_id = repmat([1:T]', [size(data(:,1),1)/T 1]); 
newp_id = repmat([1:size(data(:,1),1)/T]', [T 1]); newp_id = sort(newp_id);
%Data with new identifiers
new_T = [newp_id newt_id data(:,3:5)];

ko = data(:,3);
ko(2:size(ko,1),2) = ko(2:size(ko,1),1)./ko(1:size(ko,1)-1,1)-1; % growth rate of investment
ko(newt_id==1,2) = nan;
new_T(:,6) = ko(:,2);
xx = zeros(size(ko(:,1)));

% Parameters
delta = 4.1/100; % depreciation

capital = ones(size(data(:,3),1),1); 
capital_g = nan(size(data(:,3),1),1); 

reference_growth = data([data(:,2)==11],4); % average growth rate of current expenditures
opt_cap0 = zeros(size(reference_growth));
opt_cap_flag = zeros(size(reference_growth));

%% 1. Find initial capital values for each school district
for i_i = 1:max(newp_id) % 1:N
    [opt_cap0(i_i,1), ~, opt_cap_flag(i_i,1)] = fminsearch(@(cap0) meancap(new_T,i_i,cap0,reference_growth(i_i),newt_id,delta),1);
end
%if flag = 1, function converge to a solution

%% 2. Reconstruct capital stock
cap      = zeros(size(newp_id,1),3);

for i_i = 1:max(newp_id) % 1:N
    i_l = (i_i-1)*max(newt_id) + 1; % to stack the capital stock series vertically
    i_h = (i_i)*max(newt_id);
    cap(i_l,1) = opt_cap0(i_i);
    cap(i_l,2) = opt_cap_flag(i_i);
    cap(i_l,3) = nan;
    for i_j = i_l:i_h-1
        cap(i_j+1,1) = data(i_j,3) + cap(i_j,1)*(1-delta); % law of motion
        cap(i_j+1,2) = cap(i_j,2);
        cap(i_j+1,3) = cap(i_j+1,1)/cap(i_j,1)-1; % growth rate of capital
    end
end

% All pieces together
data_capital = [data cap];
data_capital(:,9) = data_capital(:,6)./data_capital(:,5);
data1(:,6:9) = array2table(data_capital(:,6:9));
data1.Properties.VariableNames(6:9) = {'capital','capital_indicator','capital_growth','capital_pc'};
writetable(data1,'C:\Users\edloaeza\Dropbox\SchoolDistrict2022\replication\data\k.txt');
%histogram(data_capital(:,9)) 

%% Objective Function to minimize
function xx = meancap(new_T,i_i,cap0,reference_growth,newt_id,d)
    inv = new_T([new_T(:,1)==i_i],3); % grab the investment for the i school district
    cap = zeros(size(inv));
    cap_g = nan(size(inv));
    cap(1) = cap0;
    for i_j = 1:max(newt_id)-1 % 1:37
        cap(i_j+1,1)   = inv(i_j,1) + cap(i_j,1)*(1-d); % law of motion of capital
        cap_g(i_j+1,1) = cap(i_j+1,1)./cap(i_j,1)-1; % growth rate of capital
    end
    
    %disp(reference_growth); disp(mean(cap_g(2:size(inv,1))));
    xx = (mean(cap_g(2:size(inv,1)))-reference_growth)^2;  % objective function, 
    % minimize the sqr of the difference btw growth rate of k and growth
    % rate of current expenditres
    
end







