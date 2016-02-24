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

for i = 1:26
    datax = CR25r7.SA(CR25.r7.pos(i):15:CR25.r7.pos(i+1));
    datay = -CR25r7.FY(CR25.r7.pos(i):15:CR25.r7.pos(i+1));
    name = strcat('Run', num2str(i));
    coEff = cat(2, coEff, Pacejka_lbs(datax, datay));
end


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


end