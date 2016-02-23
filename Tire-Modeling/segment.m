function n = segment(input, start, stop, threshold1, threshold2)
%{ 
find the transitions in normal force FZ and lists the points where transitions 
occur in a struct field called segs

start - start of useful 7in rim data
stop - end of useful 7in rim data
threshold1 - used for finding transition in normal force
threshold2 - used for finding transition between pressures
%}

P = input.P;   % [kpa] pressue
SA = input.SA; % [deg] slip angle
IA = input.IA; % [deg] camber angle
FZ = input.FZ; % [N] normal force


%% Find Transitions In Normal Force
% find derivative of normal force by finding difference between points
shiftFZ = circshift(FZ, 1); % shift normal force array
shiftFZ(1) = FZ(1); % eliminate first point which was last index
dFZ = shiftFZ - FZ; % subtract previous points from following points

% find transitions where derivative exceeds threshold
jumps = abs(dFZ) > threshold1; % transition positions in binary
dFZ = jumps.*dFZ; % derivative at transition positions
pos = find(abs(dFZ) > 0); % positions where transitions occur

% remove positions that come before and after useful data
temp = (pos >= start) & (pos <= stop);
pos = pos(temp);


%% Find Transitions In Pressure
% find derivative of transitions in normal force
shiftPos = circshift(pos, 1);
shiftPos(1) = pos(1);
dPos = shiftPos - pos;

% find transitions where derivative strays from normal value
jumps = abs(dPos) < 30  



flyers = [];
for i = 2:(numel(pos)-1)
    stepDown = pos(i) - pos(i-1);
    stepUp = pos(i+1) - pos(i);
    if stepDown & stepUp < threshold2
        flyers = [flyers, (pos(i) - start)];
    end
end

input.segs = pos;
n = input;

%% Plot Data To Confirm Range Of Data
figure('Name', 'Orientation & Pressure')
subplot(2, 1, 1)
hold all
plot(P, 'r')
plot(IA, 'b')
plot(SA, 'g')
title('Orientation & Pressure')
legend('Pressure', 'Camber', 'Slip Angle', 'Location', 'eastoutside')
axis([0 length(P) -inf inf])

subplot(2, 1, 2)
hold all
plot(start:stop, P(start:stop), 'r')
plot(start:stop, IA(start:stop), 'b')
plot(start:stop, SA(start:stop), 'g')
title('Orientation & Pressure')
legend('Pressure [kPa]', 'Camber [deg]', 'Slip Angle [deg]', 'Location', 'eastoutside')
axis([0 length(P) -inf inf])


figure('Name', 'Normal Force')
subplot(2, 1, 1)
hold all
plot(FZ, 'r')
plot(dFZ, 'b')
scatter(flyers,zeros(1,numel(flyers)),'og')
title('Normal Load [N]')
legend('Normal Load', 'Normal Load Derivative', 'Location', 'eastoutside')
axis([0 length(FZ) -inf inf])

subplot(2, 1, 2)
hold all
plot(start:stop, FZ(start:stop), 'r')
scatter(pos, FZ(pos), 'b')
scatter(flyers,zeros(1,numel(flyers)),'og')
title('Normal Load [N]')
legend('Normal Load', 'Location', 'eastoutside')
axis([0 length(FZ) -inf inf])

end