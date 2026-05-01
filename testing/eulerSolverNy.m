function [t,y] = eulerSolverNy(h,tid,y, trumRadie, vridPunktLangdA, vridPunktLangdB, friktionsKoefficient, hjul, hjulMassa, hissMassa, hissArea, malAcceleration, Kp, Ki, Kd, alpha)

    % Tillstånd
    hojd = y(1);
    v = y(2);
    varmeEnergi = y(3);
    bromsKraft = max(0, y(4));   % filtrerad kraft
    trumTemperatur = y(5);
    integralFel = y(6);

    % Spara föregående styrsignal
    bromsKraft_old = bromsKraft;

    % Konstanter
    specifikVarmeKapacitetMaterial = 500;
    materialMassa = 50;
    varmeKapacitet = specifikVarmeKapacitetMaterial * materialMassa;

    mu0 = friktionsKoefficient;

    y_ut = y;
    t_ut = 0;

    a = 0;
    error_gammal = malAcceleration - a;

    for i = h:h:tid
        if v < -0.01  % Om hastigheten är mer än 1 cm/s nedåt, reglera!
            [bromsKraft_raw, integralFel, error_gammal] = ...
                eulerSolverPIDNy(malAcceleration, a, integralFel, error_gammal, h, Kp, Ki, Kd);
        else
            % Hissen är så gott som stilla - nollställ allt direkt
            v = 0;
            a = 0;
            bromsKraft_raw = 0;
            integralFel = 0; 
        end

        % ===== ALPHA-FILTER =====
        bromsKraft = (1 - alpha)*bromsKraft_old + alpha*bromsKraft_raw;
        bromsKraft_old = bromsKraft;

        % ===== TEMPERATURBEROENDE FRIKTION =====
        mu = mu0;
        if trumTemperatur > 300 + 273.15
            deltaT = trumTemperatur - (300 + 273.15);
            mu = max(0, mu0 * (1 - deltaT/150));
        end

        % ===== UTVÄXLING =====
        if hjul == 1
            utVaxling = 1/2;
        else
            utVaxling = 1;
        end

        % ===== BROMSMODELL =====
        kraftPrimarback = (bromsKraft * vridPunktLangdA) / ((vridPunktLangdA/2)-mu*vridPunktLangdB);
        kraftSekundarback = (bromsKraft * vridPunktLangdA) / ((vridPunktLangdA/2)+mu*vridPunktLangdB);

        bromsKraftRep = (kraftPrimarback + kraftSekundarback) * mu * utVaxling;

        % ===== LUFTMOTSTÅND =====
        cd = 1.5;
        rho = 1.2;
        luftMotstandsKraft = cd * rho * ((v^2)/2) * hissArea * sign(v);

        % ===== TYNGDKRAFT =====
        tyngdKraft = (hissMassa - (hjulMassa/2)) * 9.82;

        % ===== DYNAMIK =====
        kraftTot = tyngdKraft - (luftMotstandsKraft + bromsKraftRep);
        a = -kraftTot / (hissMassa + (hjulMassa/4));

        % ===== STOPPLOGIK =====
        if v >= 0
            v = 0;
            a = 0;
        end

        % ===== ENERGI =====
        varmeEffekt = abs(bromsKraftRep * v);
        dTdt = varmeEffekt / varmeKapacitet;

        % ===== EULER =====
        hojd = hojd + v*h;
        v = v + a*h;
        varmeEnergi = varmeEnergi + varmeEffekt*h;
        trumTemperatur = trumTemperatur + dTdt*h;

        % ===== SPARA =====
        y_ut = [y_ut; hojd, v, varmeEnergi, bromsKraft, trumTemperatur, integralFel];
        t_ut = [t_ut; i];
    end

    t = t_ut;
    y = y_ut;
end