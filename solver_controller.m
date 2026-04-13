clear all;
close all;

%function dydt = solver(y0, bromsKraft, trumRadie, vridPunktLangdA, vridPunktLangdB, friktionsKoefficient, utVaxling, hjulMassa, hissMassa, hissArea)

bromsKraft = 4500;
trumRadie = 0.2;
vridPunktLangdA = 0.1;
vridPunktLangdB = 0.05;
friktionsKoefficient = 0.2;
utVaxling = 1;
hjulMassa = 10;
hissMassa = 300;
hissArea = 2;

%Begynnelsevärden:
hojd = 100;
hastighet = -10;
varmeEnergi = 0;

y0 = [hojd, hastighet, varmeEnergi];

ode_fun = @(t,y) solver(t, y, bromsKraft, trumRadie, vridPunktLangdA, vridPunktLangdB, friktionsKoefficient, utVaxling, hjulMassa, hissMassa, hissArea);

[t,y] = ode45(ode_fun,[0,30],y0);

plot(t,y(:,1)); %Höjden
figure;

plot(t,y(:,2)); %Hastigheten
figure;

acceleration = diff(y(:,2));
plot(t(1:end-1), acceleration); %Accelerationen
figure;

bromsEffekt = diff(y(:,3));
plot(t(1:end-1), bromsEffekt); %bromsEffekt
