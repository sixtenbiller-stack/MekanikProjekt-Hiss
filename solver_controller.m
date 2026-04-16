clear all;
close all;

%function dydt = solver(y0, bromsKraft, trumRadie, vridPunktLangdA, vridPunktLangdB, friktionsKoefficient, utVaxling, hjulMassa, hissMassa, hissArea)

bromsKraft = 3000;
trumRadie = 0.2;
vridPunktLangdA = 0.1;
vridPunktLangdB = 0.05;
friktionsKoefficient = 0.2;
utVaxling = 1;
hjulMassa = 10;
hissMassa = 300;
hissArea = 2;
malAcceleration = 1;

%Begynnelsevärden:
hojd = 0;
hastighet = -10;
varmeEnergi = 0;

y0 = [hojd, hastighet, varmeEnergi, bromsKraft];

ode_fun = @(t,y) solver(t, y, trumRadie, vridPunktLangdA, vridPunktLangdB, friktionsKoefficient, utVaxling, hjulMassa, hissMassa, hissArea, malAcceleration);

[t,y] = ode45(ode_fun,[0,15],y0);

plot(t,y(:,1)); %Höjden
title("Höjd/Tid");
figure;

plot(t,y(:,2)); %Hastigheten
title("Hastighet/Tid");
figure;

acceleration = diff(y(:,2))./diff(t);
plot(t(1:end-1), acceleration); %Accelerationen
title("Acceleration/Tid");
figure;

bromsEffekt = diff(y(:,3))./diff(t);
plot(t(1:end-1), bromsEffekt); %bromsEffekt
title("Bromseffekt (värme-effekt) /Tid");
figure;

plot(t,y(:,4))
title("Applicerad bromskraft/Tid"); %Bromskraft (kraften på vardera back)