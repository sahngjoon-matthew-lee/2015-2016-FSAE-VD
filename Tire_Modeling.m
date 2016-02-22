function coEff = Tire_Modeling()

clc
close all
format long


%% R25B Non-Driven Behavior
% R25B data
CR25_7.r20 = load('Round 5 SI/B1464run20.mat'); % -
CR25_7.r21 = load('Round 5 SI/B1464run21.mat'); % -

CR25r7 = combine(CR25_7.r20, CR25_7.r21); % -
CR25r7 = timeSplice(CR25r7, CR25_7.r20, CR25_7.r21);

% Defined start and end of the useful data
CR25r7.start = 8450; % start of useful 7in rim data (8450)
CR25r7.end = 120200; % end of useful 7in rim data6  (117200)

% Break data into segments
CR25r7.shiftFZ = circshift(CR25r7.FZ, 1); % shift normal force array
CR25r7.shiftFZ(1) = CR25r7.FZ(1);
CR25r7.dFZ = CR25r7.shiftFZ - CR25r7.FZ; % find derivative in normal force
CR25r7.jumps = abs(CR25r7.dFZ) > 125; % jump positions in binary
CR25r7.dFZ = CR25r7.jumps.*CR25r7.dFZ; % jump position values
CR25r7.pos = find(CR25r7.jumps > 0); % positions where jumps occur
temp2 = CR25r7.pos >= CR25r7.start; % remove positions that come before useful data
CR25.r7.trimPos = CR25r7.pos(temp2); % useful positions where jumps occur
temp3 = CR25.r7.trimPos <= CR25r7.end; % remove positions that come after useful data
CR25.r7.pos = CR25.r7.trimPos(temp3); % useful positions where jumps occur
CR25.r7.jumps = CR25r7.jumps*15; % increase scale of binary jump positions
pos2 = CR25.r7.pos;

flyers = [];
for indx = 2:(numel(pos2)-1)
    stepDown = pos2(indx) - pos2(indx-1);
    stepUp = pos2(indx+1) - pos2(indx);
    if stepDown & stepUp < 800
        flyers = [flyers (pos2(indx)-CR25r7.start)];
    end
end

%% Pacejka Fit
coEff = [];

Pressures = [12 10 14 8 12];
Cambers = [0 2 4 1 3];
Loads = [200 150 50 250 100];

conditions = zeros(); %defines pressure, angle, and loading conditions for later graphing

for i = 1:25
    datax = CR25r7.SA(CR25.r7.pos(i):15:CR25.r7.pos(i+1));
    datay = -CR25r7.FY(CR25.r7.pos(i):15:CR25.r7.pos(i+1));
    name = strcat('Run ', num2str(i));
    conditions(i,1) = Pressures(1);  %stating current pressure
    conditions(i,2) = Cambers(int32(idivide(int32(i-1),int32(5),'floor'))+1);
    conditions(i,3) = Loads(mod(i-1,5)+1);
    coEff = cat(1, coEff, Pacejka(datax, datay));
end

conditions

conditions([1:5:21],[1:end])

%% C R25B 7in Rim Data
figure('Name', 'C R25B 7in Rim')
subplot(2, 1, 1)
hold all
plot(CR25r7.P(CR25r7.start:CR25r7.end), 'r')
plot(CR25r7.IA(CR25r7.start:CR25r7.end), 'b')
plot(CR25r7.SA(CR25r7.start:CR25r7.end), 'g')
%plot(CR25r7.jumps(CR25r7.start:CR25r7.end), 'k')
title('Pressure [kPa], Camber [deg], Slip Angle [deg]')
legend('Pressure', 'Camber', 'Slip Angle') %, 'Jumps')

color2 = -300 > CR25r7.FZ;
color2 = CR25r7.FZ.*color2;

subplot(2, 1, 2)
hold all
plot(CR25r7.FZ(CR25r7.start:CR25r7.end), 'r')
plot(CR25r7.dFZ(CR25r7.start:CR25r7.end), 'b')
scatter(flyers,zeros(1,numel(flyers)),'og')
%scatter([pos2(93)-CR25r7.start+1, pos2(119)-CR25r7.start+1], [CR25r7.dFZ(pos2(93)), CR25r7.dFZ(pos2(119))], 10, 'g')
%scatter(0:CR25r7.end - CR25r7.start, color2(CR25r7.start:CR25r7.end), 1, 'k')
title('Normal Load [N]')
%legend('Normal Load', 'd Normal Load')


%% Plotting coefficient changes

for n = 1:5

nAm3 = strcat('B Camber Change at ',num2str(conditions(n,3)),'lbf Loading');
figure('name',nAm3)
hold all
plot(conditions([n:5:20+n],2),coEff([n:5:20+n],1),'or')
nAm3 = strcat('C Camber Change at ',num2str(conditions(n,3)),'lbf Loading');
figure('name',nAm3)
hold all
plot(conditions([n:5:20+n],2),coEff([n:5:20+n],2),'og')
nAm3 = strcat('D Camber Change at ',num2str(conditions(n,3)),'lbf Loading');
figure('name',nAm3)
hold all
plot(conditions([n:5:20+n],2),coEff([n:5:20+n],3),'ob')
nAm3 = strcat('E Camber Change at ',num2str(conditions(n,3)),'lbf Loading');
figure('name',nAm3)
hold all
plot(conditions([n:5:20+n],2),coEff([n:5:20+n],4),'ok')
% legend('B','C','D','E')

Nam3 = strcat('B Load Change at ',num2str(conditions(5*n,2)),'deg Camber');
figure('name',Nam3)
hold all
plot(conditions([5*n-4:5*n],3),coEff([5*n-4:5*n],1),'or')
Nam3 = strcat('C Load Change at ',num2str(conditions(5*n,2)),'deg Camber');
figure('name',Nam3)
hold all
plot(conditions([5*n-4:5*n],3),coEff([5*n-4:5*n],2),'og')
Nam3 = strcat('D Load Change at ',num2str(conditions(5*n,2)),'deg Camber');
figure('name',Nam3)
hold all
plot(conditions([5*n-4:5*n],3),coEff([5*n-4:5*n],3),'ob')
Nam3 = strcat('E Load Change at ',num2str(conditions(5*n,2)),'deg Camber');
figure('name',Nam3)
hold all
plot(conditions([5*n-4:5*n],3),coEff([5*n-4:5*n],4),'ok')
legend('B','C','D','E')

end

end