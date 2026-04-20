clear all;
close all;

bromsKraft = 300;
trumRadie = 0.6;
vridPunktLangdA = 0.30;
vridPunktLangdB = 0.15;
friktionsKoefficient = 0.2;
hjul = 2;
hjulMassa = 600; %Denna agerar motvikt
hissMassa = 300;
hissArea = 2;
malAcceleration = 1.2;

%Regler-loop (PID)
Kp = 10000;
Ki = 100;
Kd = 35;

%Begynnelsevärden:
hojd = 0;
hastighet = -10;
varmeEnergi = 0;

y0 = [hojd, hastighet, varmeEnergi, bromsKraft, 293.15, 0];

ode_fun = @(t,y) solver(t, y, trumRadie, vridPunktLangdA, vridPunktLangdB, friktionsKoefficient, hjul, hjulMassa, hissMassa, hissArea, malAcceleration, Kp, Ki, Kd);

[t,y] = ode45(ode_fun,[0,10],y0);

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

plot(t, y(:,3)); %Bromsad energi
title("Bromsad energi/tid");
figure;

plot(t, max(0, y(:,4)))
title("Applicerad bromskraft/Tid"); %Bromskraft (kraften på vardera back)
figure;

plot(t,y(:,5))