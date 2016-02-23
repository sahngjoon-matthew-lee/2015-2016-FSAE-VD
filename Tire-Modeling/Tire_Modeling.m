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

ET = CR25.ET;
P = CR25.P;
SA = CR25.SA;
IA = CR25.IA;
FX = CR25.FX;
FY = CR25.FY;
FZ = CR25.FZ;
MX = CR25.MX;
MZ = CR25.MZ;

% Defined start and end of the useful data
CR25.start = 8450; % start of useful 7in rim data (8450)
CR25.end = 120200; % end of useful 7in rim data6  (117200)

% Break data into segments
CR25.shiftFZ = circshift(CR25.FZ, 1); % shift normal force array
CR25.shiftFZ(1) = CR25.FZ(1);
CR25.dFZ = CR25.shiftFZ - CR25.FZ; % find derivative in normal force
CR25.jumps = abs(CR25.dFZ) > 125; % jump positions in binary
CR25.dFZ = CR25.jumps.*CR25.dFZ; % jump position values
CR25.pos = find(CR25.jumps > 0); % positions where jumps occur
temp2 = CR25.pos >= CR25.start; % remove positions that come before useful data
CR25.r7.trimPos = CR25.pos(temp2); % useful positions where jumps occur
temp3 = CR25.r7.trimPos <= CR25.end; % remove positions that come after useful data
CR25.r7.pos = CR25.r7.trimPos(temp3); % useful positions where jumps occur
CR25.r7.jumps = CR25.jumps*15; % increase scale of binary jump positions
pos2 = CR25.r7.pos;

flyers = [];
for indx = 2:(numel(pos2)-1)
    stepDown = pos2(indx) - pos2(indx-1);
    stepUp = pos2(indx+1) - pos2(indx);
    if stepDown & stepUp < 800
        flyers = [flyers (pos2(indx)-CR25.start)];
    end
end

%% Pacejka Fit
coEff = [];

Pressures = [12 10 14 8 12];
Cambers = [0 2 4 1 3];
Loads = [200 150 50 250 100];

conditions = zeros(); %defines pressure, angle, and loading conditions for later graphing

for i = 1:25
    datax = CR25.SA(CR25.r7.pos(i):15:CR25.r7.pos(i+1));
    datay = -CR25.FY(CR25.r7.pos(i):15:CR25.r7.pos(i+1));
    conditions(i,1) = Pressures(1);  %stating current pressure
    conditions(i,2) = Cambers(int32(idivide(int32(i-1),int32(5),'floor'))+1);
    conditions(i,3) = Loads(mod(i-1,5)+1);
    coEff = cat(1, coEff, Pacejka(datax, datay));
end

disp(coEff)
disp(conditions)


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





%% C R25B 7in Rim Data
figure('Name', 'C R25B 7in Rim')
subplot(2, 1, 1)
hold all
plot(CR25.P(CR25.start:CR25.end), 'r')
plot(CR25.IA(CR25.start:CR25.end), 'b')
plot(CR25.SA(CR25.start:CR25.end), 'g')
%plot(CR25r7.jumps(CR25r7.start:CR25r7.end), 'k')
title('Pressure [kPa], Camber [deg], Slip Angle [deg]')
legend('Pressure', 'Camber', 'Slip Angle') %, 'Jumps')

color2 = -300 > CR25.FZ;
color2 = CR25.FZ.*color2;

subplot(2, 1, 2)
hold all
plot(CR25.FZ(CR25.start:CR25.end), 'r')
plot(CR25.dFZ(CR25.start:CR25.end), 'b')
scatter(flyers,zeros(1,numel(flyers)),'og')
%scatter([pos2(93)-CR25r7.start+1, pos2(119)-CR25r7.start+1], [CR25r7.dFZ(pos2(93)), CR25r7.dFZ(pos2(119))], 10, 'g')
%scatter(0:CR25r7.end - CR25r7.start, color2(CR25r7.start:CR25r7.end), 1, 'k')
title('Normal Load [N]')
%legend('Normal Load', 'd Normal Load')




end