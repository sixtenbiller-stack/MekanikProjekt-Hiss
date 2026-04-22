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

plot(t,y(:,1),'LineWidth',6); %Höjden
title("Höjd över Tid");
xlabel('Tid [s]');
ylabel('Höjd [m]');
ax = gca;
ax.FontSize = 16;
grid on;
figure;

plot(t,y(:,2),'LineWidth',6); %Hastigheten
title("Hastighet över Tid");
xlabel('Tid [s]');
ylabel('Hastighet [m/s]');
ax = gca;
ax.FontSize = 16;
grid on;
figure;

acceleration = diff(y(:,2))./diff(t);
plot(t(1:end-1), acceleration,'LineWidth',4); %Accelerationen
title("Acceleration över Tid");
xlabel('Tid [s]');
ylabel('Acceleration [m/s^2]');
ax = gca;
ax.FontSize = 16;
grid on;
figure;

bromsEffekt = diff(y(:,3))./diff(t);
plot(t(1:end-1), bromsEffekt,'LineWidth',6); %BromsEffekt
title("Bromseffekt (värme-effekt) över Tid");
xlabel('Tid [s]');
ylabel('Bromseffekt [J/s]');
ax = gca;
ax.FontSize = 16;
grid on;
figure;

plot(t, y(:,3),'LineWidth',6); %Bromsad energi
title("Bromsad energi över tid");
xlabel('Tid [s]');
ylabel('Bromsad energi [J]');
ax = gca;
ax.FontSize = 16;
grid on;
figure;


bromsKraft = y(:,4);
bromsKraft(abs(y(:,2)) < 0.01) = 0;
plot(t,bromsKraft ,'LineWidth',6);
title("Applicerad bromskraft över Tid"); %Bromskraft (kraften på vardera back)
xlabel('Tid [s]');
ylabel('Applicerad bromskraft [N]');
ax = gca;
ax.FontSize = 16;
grid on;
figure;

plot(t,y(:,5),'LineWidth',6);
title("Bromstemperatur över Tid"); %Bromsens temperatur i helhet
xlabel('Tid [s]');
ylabel('Bromstemperatur [K]');
ax = gca;
ax.FontSize = 16;
grid on;