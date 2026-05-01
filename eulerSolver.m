function [t,y] = eulerSolver(h,tid, y, trumRadie, vridPunktLangdA, vridPunktLangdB, friktionsKoefficient, hjul, hjulMassa, hissMassa, hissArea, malAcceleration, Kp, Ki, Kd)
    %Initierar startvärden (begynnelsevärden)
    hojd = y(1); %Höjd (för själva hissen)
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

    y_ut = [y];
    t_ut = [0];

    a = 0;
    error = malAcceleration - a;
    error_gammal = error; % <--- Sätt denna till det initiala felet istället för 0

    for i = (h:h:tid);
        % 1. Beräkna felet
        error = malAcceleration - a;

        % 2. Integraldel
        ackumuleratFel = ackumuleratFel + error * h;

        % 3. Derivatadel
        d_error = (error - error_gammal) / h;
        error_gammal = error;

        % 4. Sätt bromskraften direkt
        % Här blir bromsKraft summan av de tre termerna
        bromsKraft = Kp * error + Ki * ackumuleratFel + Kd * d_error;

        % 5. Fysisk begränsning
        % Bromsen kan inte ha negativ kraft (skjuta hissen uppåt)
        bromsKraft = max(0, bromsKraft); % Fysisk begränsning

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
        
        % if v >= 0
        %     bromsKraftRep = bromsKraftRep * 1.25; %Hanterar icke-glidning
        %     kraftTot = tyngdKraft - (luftMotstandsKraft + bromsKraftRep);
        %     a = -kraftTot / (hissMassa + (hjulMassa/4));
        %     %I fallet att hissen har stannat
        %     v = 0;
        %     a = 0;
        % end

        if v + a * h >= 0
            v = 0;
            a = 0;
            % Lägg till sista punkten och avsluta simuleringen
            y_ut = [y_ut; hojd, v, varmeEnergi, bromsKraft, trumTemperatur, ackumuleratFel];
            t_ut = [t_ut; i];
            break; 
        end
    
        %Spillvärme-effekten beräknad genom att ta bromskraften (i repet)
        %multiplicerad med hastigheten
        varmeEffekt = abs(bromsKraftRep * v);
        dtrumTemperaturdt = varmeEffekt/varmeKapacitet;
    
        %Applicera derivatorna i diff-ekvationen
        hojd = hojd + v * h;
        v = v + a * h;
        varmeEnergi = varmeEnergi + varmeEffekt * h;
        % bromsKraft = bromsKraft + dbromskraftdt * h;
        trumTemperatur = trumTemperatur + dtrumTemperaturdt * h;
        % ackumuleratFel = dAckumuleratFeldt;
        y_ut = [y_ut;hojd,v,varmeEnergi,bromsKraft,trumTemperatur,ackumuleratFel];
        t_ut = [t_ut;i];

    end
    t = t_ut;
    y = y_ut;
end