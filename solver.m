function dydt = solver(t, y, trumRadie, vridPunktLangdA, vridPunktLangdB, friktionsKoefficient, hjul, hjulMassa, hissMassa, hissArea, malAcceleration, Kp, Ki, Kd)
    %Initierar startvärden (begynnelsevärden)
    h = y(1); %Höjd (för själva hissen)
    v = y(2); %Hastighet (positivt hastighet uppåt)
    varmeEnergi = y(3); %Värmeenergiutveckling under processen
    bromsKraft = y(4); %Bromskraften under inbromsningen
    bromsKraft = max(0, y(4)); % Bromsen kan aldrig trycka mindre än 0 Newton, och
                               % därmed aldrig råka trycka hissen uppåt
                               % istället.
    trumTemperatur = y(5); %Temperaturen av bromsen i sin helhet

    specifikVarmeKapacitetMaterial = 500; %J/(kg*k), vi tänker att det är stål
    materialMassa = 50; %kg
    varmeKapacitet = specifikVarmeKapacitetMaterial * materialMassa;
    ackumuleratFel = y(6);

    if hjul == 1
        %Om bromsen ligger på det vänstra hjulet kommer repet att röra sig
        %2x dess omkrets per rotation.
        utVaxling = 1/2; 
    else
        %För det högra hjulet rör sig repet lika långt som dess omkrets
        %under en rotation, alltså behövs inte kraften skalas om.
        utVaxling = 1;
    end

    %Vi tänker att bromsen tappar sin fritkionskoefficient linjärt efter 300c
    if trumTemperatur > 300+273.15
        deltaT = trumTemperatur - (300 + 273.15);
        friktionsKoefficient = friktionsKoefficient - (friktionsKoefficient * (deltaT / 150));
    end
    friktionsKoefficient = max(0,friktionsKoefficient);

    %Dessa är funktionerna lösta i tentauppgiften, alltså, kraften på
    %vardera back inklusive förstärkning/försvagningskraften inräknad
    kraftPrimarback = (bromsKraft * vridPunktLangdA) / ((vridPunktLangdA/2)-friktionsKoefficient*vridPunktLangdB);
    kraftSekundarback = (bromsKraft * vridPunktLangdA) / ((vridPunktLangdA/2)+friktionsKoefficient*vridPunktLangdB);
    
    %Den faktiska bromskraften som appliceras på repet
    bromsKraftRep = (kraftSekundarback + kraftPrimarback) * friktionsKoefficient * utVaxling;

    %Nasa drag equation, för att uppskatta luftmotståndskraften
    cd = 1.5;
    rho = 1.2;
    A = hissArea;
    luftMotstandsKraft = cd * rho * ((v^2)/2) * A * sign(v);

    %Tyngdkraften beräknad för hela systemet.
    %I detta fall hänger hjulet på motsatt sida av hissen och därmed
    %motverkar korgens tyngdkraft
    tyngdKraft = (hissMassa - (hjulMassa/2)) * 9.82;

    %Kraftresultanten av systemet
    kraftTot = tyngdKraft - (luftMotstandsKraft + bromsKraftRep);

    %Beräkna den resulterande accelerationen skapad av bromskraften på
    %repet
    a = -kraftTot / (hissMassa + (hjulMassa/4));

    %Systemet som möjliggör hissen att ändra sin bromskraft beroende på
    %belastningen och siktar på att hålla en konstant acceleration
    %vilket ges av malAcceleration
    
    if v >= 0
        bromsKraftRep = bromsKraftRep * 1.25; %Hanterar icke-glidning
        kraftTot = tyngdKraft - (luftMotstandsKraft + bromsKraftRep);
        a = -kraftTot / (hissMassa + (hjulMassa/4));
        %I fallet att hissen har stannat
        v = 0;
        if a>0
            a = 0;
        end
    end

    %Spillvärme-effekten beräknad genom att ta bromskraften (i repet)
    %multiplicerad med hastigheten
    varmeEffekt = abs(bromsKraftRep * v);
    dtrumTemperaturdt = varmeEffekt/varmeKapacitet;

    error = malAcceleration - a;

    %persistent a_old
    %if isempty(a_old)
    %    a_old = a; 
    %end

    %da_dt = (a - a_old) / 0.01; % En enkel approximation av accelerationens förändring
    %a_old = a;

    % 3. Den slutgiltiga PID-ekvationen för bromskraftens förändring
    dbromskraftdt = Kp * error + Ki * ackumuleratFel;

    dAckumuleratFeldt = error;

    %Applicera derivatorna i diff-ekvationen
    dydt = [
        v;                  % dy(1)
        a;                  % dy(2)
        varmeEffekt;        % dy(3)
        dbromskraftdt;      % dy(4)
        dtrumTemperaturdt;  % dy(5)
        dAckumuleratFeldt   % dy(6)
    ];
end