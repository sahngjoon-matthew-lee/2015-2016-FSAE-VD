function coEff = Pacejka(input, output)
%{
Returns Pacejka coefficients B, C, D, E

Based on The Magic Tyre Formula by Hans B. Pacejka from the CMU Library
electronic database

All units are in SI (radians, newton, newton*meter, etc)

Base function: y = D*sin(C*atan(B*x-E*(B*x-atan(B(1)*x))))

For output:
    -cornering force (N) -> C = 1.3
    -aligning torque (N*m) -> C = 2.4
    -brake force (N*m) -> C = 1.65

D = the peak of the output

B = slope(@ x = 0)/(C*D)

E = (B*xmax - tan(pi/(2*C)))/(B*xmax - atan(B*xmax))

%}

input = degtorad(input);

C = 1.3;

[D, maxpos] = max(output);

pos = find(abs(input) < degtorad(1));
delt = polyfit(input(pos), output(pos), 1);
B = delt(1)/(C*D);

E = (B*input(maxpos) - tan(pi/(2*C)))/(B*input(maxpos) - atan(B*input(maxpos)));

x0 = [B C D E];

y = @(x, xdata) x(3)*sin(x(2)*atan(x(1)*xdata - x(4)*(x(1)*xdata - atan(x(1)*xdata))));  % 
opt = optimoptions(@lsqcurvefit);
opt.MaxFunEvals = 10000;
opt.MaxIter = 10000;
opt.Display = 'off';
lb = [];
ub = [];
coEff = lsqcurvefit(y, x0, input, output, lb, ub, opt);

y = @(x) coEff(3)*sin(coEff(2)*atan(coEff(1)*x - coEff(4)*(coEff(1)*x - atan(coEff(1)*x))));

% figure()
% hold on
% scatter(input, output, 3, 'ob')
% fplot(y, [degtorad(-15) degtorad(15)], 'r')


end