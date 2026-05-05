clear all;
close all;

%function dydt = solver(y0, bromsKraft, trumRadie, vridPunktLangdA, vridPunktLangdB, friktionsKoefficient, hjul, hjulMassa, hissMassa, hissArea)

bromsKraft = 300;
trumRadie = 0.6;
vridPunktLangdA = 0.30;
vridPunktLangdB = 0.15;
friktionsKoefficient = 0.2;
hjul = 2;
hjulMassa = 600; %Denna agerar motvikt
hissArea = 2;
malAcceleration = 1.2;

%Regler-loop (PID)
Kp = 0;
Ki = 3000;
Kd = 0;

%Begynnelsevärden:
hojd = 0;
hastighet = -20;
varmeEnergi = 0;

y0 = [hojd, hastighet, varmeEnergi, bromsKraft, 293.15, 0];

startMassa = 200;
slutMassa = 3000;
massaSpan  = startMassa:25:slutMassa;

tid = 25;
h = 0.01;

Z = zeros(length(massaSpan),tid/h+1);
i = 1;
for m = massaSpan
   
   [t,y] = eulerSolver(h,tid,y0,trumRadie, vridPunktLangdA, vridPunktLangdB, friktionsKoefficient, hjul, hjulMassa, m, hissArea, malAcceleration, Kp, Ki, Kd);
   
   appliceringsKraft = y(:, 4);
   appliceringsKraft(y(:,2)>-0.1) = 0;
   Z(i, :) = appliceringsKraft;
   i = i+1;
end
[T, M_grid] = meshgrid(t, massaSpan);
figure
s = surf(T, M_grid, Z);
ax = gca; 
ax.FontSize = 18;
colormap turbo
s.EdgeAlpha = 0.2;

xlabel('Tid [s]')
ylabel('Massa [kg]')
zlabel('Appliceringskraft [N]')
title('Bromskraftsappliceringskraft med massa och tid')