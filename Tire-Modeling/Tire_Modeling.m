function Tire_Modeling()

clc
close all
format long


%% R25B Non-Driven Behavior
% R25B data
r20 = load('Round-5-SI/B1464run20.mat'); % loading round 20 data
r21 = load('Round-5-SI/B1464run21.mat'); % loading round 21 data

CR25 = combine(r20, r21); % -
CR25 = timeSplice(CR25, r20, r21);
CR25 = segment(CR25, 8450, 117280, 125, 800);

ET = CR25.ET; % [s] elapsed time
P = CR25.P;   % [kpa] pressue
SA = CR25.SA; % [deg] slip angle
IA = CR25.IA; % [deg] camber angle
FX = CR25.FX; % [N] longitudinal force
FY = CR25.FY; % [N] lateral force
FZ = CR25.FZ; % [N] normal force
MX = CR25.MX; % [N*m] overturning moment
MZ = CR25.MZ; % [N*m] aligning torque
pos = CR25.segs;


%% Pacejka Fit
coEff = [];

Pressures = [12 10 14 8 12];
Cambers = [0 2 4 1 3];
Loads = [200 150 50 250 100];

conditions = zeros(); %defines pressure, angle, and loading conditions for later graphing

for i = 1:25
    datax = SA(pos(i):15:pos(i+1));
    datay = -FY(pos(i):15:pos(i+1));
    conditions(i,1) = Pressures(1);  %stating current pressure
    conditions(i,2) = Cambers(int32(idivide(int32(i-1),int32(5),'floor'))+1);
    conditions(i,3) = Loads(mod(i-1,5)+1);
    coEff = cat(1, coEff, Pacejka(datax, datay));
end


%% Plotting coefficient changes
%{
figure('name','Camber Change')
hold all
scatter(conditions([1:5:21],2),coEff(1,21]),'or')
% scatter(conditions([1:end],2),coEff(1,[1:end]),'og')
% scatter(conditions([1:end],2),coEff(1,[1:end]),'ob')
% scatter(conditions([1:end],2),coEff(1,[1:end]),'ok')
legend('B','C','D','E')

figure('name','Load Change')
hold all
scatter(conditions([1:5:21],3),coEff(1,[1:5:21]),'or')
% scatter(conditions([1:end],3),coEff(1,[1:end]),'og')
% scatter(conditions([1:end],3),coEff(1,[1:end]),'ob')
% scatter(conditions([1:end],3),coEff(1,[1:end]),'ok')
legend('B','C','D','E')
%}


end