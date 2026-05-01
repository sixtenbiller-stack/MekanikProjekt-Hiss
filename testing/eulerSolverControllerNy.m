clear all;
close all;

bromsKraft = 300;
trumRadie = 0.6;
vridPunktLangdA = 0.30;
vridPunktLangdB = 0.15;
friktionsKoefficient = 0.2;
hjul = 2;
hjulMassa = 600;
hissMassa = 300;
hissArea = 2;
malAcceleration = 1.2;

h = 1/100;
tid = 15;

Kp = 0;
Ki = 3000;
Kd = 0;
alpha = 1;

hojd = 0;
hastighet = -10;
varmeEnergi = 0;

y0 = [hojd, hastighet, varmeEnergi, bromsKraft, 293.15, 0];

[t,y] = eulerSolverNy(h,tid,y0,trumRadie, vridPunktLangdA, vridPunktLangdB, friktionsKoefficient, hjul, hjulMassa, hissMassa, hissArea, malAcceleration, Kp, Ki, Kd, alpha);

plot(t,y(:,1),'LineWidth',6);
title("Höjd över Tid");
xlabel('Tid [s]');
ylabel('Höjd [m]');
grid on;
figure;

plot(t,y(:,2),'LineWidth',6);
title("Hastighet över Tid");
xlabel('Tid [s]');
ylabel('Hastighet [m/s]');
grid on;
figure;

acceleration = diff(y(:,2))./diff(t);
plot(t(1:end-1), acceleration,'LineWidth',4);
title("Acceleration över Tid");
xlabel('Tid [s]');
ylabel('Acceleration [m/s^2]');
grid on;
figure;

bromsEffekt = diff(y(:,3))./diff(t);
plot(t(1:end-1), bromsEffekt,'LineWidth',6);
title("Bromseffekt över Tid");
xlabel('Tid [s]');
ylabel('Effekt [J/s]');
grid on;
figure;

plot(t,y(:,4),'LineWidth',6);
title("Bromskraft");
grid on;