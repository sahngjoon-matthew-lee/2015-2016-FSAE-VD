function n = segment(input)
% find the transitions in normal force FZ and lists the points where
% transitions occur in a struct field called segs

FZ = input.FZ;

start = 8450; % start of useful 7in rim data (8450)
stop = 120200; % end of useful 7in rim data  (117200)
scaleVal1 = 125; % used for finding jump positions

% find derivative of normal force by finding difference between points
shiftFZ = circshift(FZ, 1); % shift normal force array
shiftFZ(1) = FZ(1); % eliminate first point  which was last index
dFZ = shiftFZ - FZ; % subtract previous points with subsequent points

jumps = abs(dFZ) > scaleVal1; % jump positions in binary
dFZ = jumps.*dFZ; % jump position values
pos = find(jumps > 0); % positions where jumps occur

temp2 = pos >= start; % remove positions that come before useful data
trimPos = pos(temp2); % useful positions where jumps occur
temp3 = trimPos <= stop; % remove positions that come after useful data
pos = trimPos(temp3); % useful positions where jumps occur
jumps = jumps*15; % increase scale of binary jump positions
input.segs = pos;
n = input;

%% C R25B 7in Rim Data
figure('Name', 'C R25B 7in Rim')
subplot(2, 1, 1)
hold all
plot(P(start:stop), 'r')
plot(IA(start:stop), 'b')
plot(SA(start:stop), 'g')
%plot(jumps(start:stop), 'k')
title('Pressure [kPa], Camber [deg], Slip Angle [deg]')
legend('Pressure', 'Camber', 'Slip Angle') %, 'Jumps')

color2 = -300 > FZ;
color2 = FZ.*color2;

subplot(2, 1, 2)
hold all
plot(FZ(start:stop), 'r')
plot(dFZ(start:stop), 'b')
scatter(flyers,zeros(1,numel(flyers)),'og')
%scatter([pos2(93)-start+1, pos2(119)-start+1], [dFZ(pos2(93)), dFZ(pos2(119))], 10, 'g')
%scatter(0:stop - start, color2(start:stop), 1, 'k')
title('Normal Load [N]')
%legend('Normal Load', 'd Normal Load')


end