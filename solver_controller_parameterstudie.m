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

%Begynnelsevärden:
hojd = 0;
hastighet = -20;
varmeEnergi = 0;

y0 = [hojd, hastighet, varmeEnergi, bromsKraft, 293.15];

startMassa = 200;
slutMassa = 3000;
massaSpan  = startMassa:25:slutMassa;

%Vi behöver definiera en gemensam tidsaxel som alla mätningar kan svara
%till
t_fix = linspace(0, 25, 100); 
Z = zeros(length(massaSpan), length(t_fix)); 

i = 1; 

for m = massaSpan
   ode_fun = @(t,y) solver(t, y, trumRadie, vridPunktLangdA, vridPunktLangdB, friktionsKoefficient, hjul, hjulMassa, m, hissArea, malAcceleration);
   
   [t, y] = ode45(ode_fun, [0, 25], y0);
   
   hastighet = y(:, 2); 
   appliceringsKraft  = y(:, 4);
   
   % Nollställ kraften vid stillastående för varje mätpunkt och 
   appliceringsKraft(abs(hastighet) < 1) = 0;
   appliceringsKraft(appliceringsKraft < 0) = 0;
   
   %Vi behöver intertpolera värdena för att passa till den gemensamma
   %tidsaxeln
   Z(i, :) = interp1(t, appliceringsKraft, t_fix, 'linear', 0);
   
   i = i + 1; 
end

[T, M_grid] = meshgrid(t_fix, massaSpan);

figure
surf(T, M_grid, Z)

xlabel('Tid (s)')
ylabel('Massa (kg)')
zlabel('Appliceringskraft (N)')
title('Bromskraftsapplicering med massa och tid')