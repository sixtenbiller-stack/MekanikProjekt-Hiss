function dydt = solver(t, y, trumRadie, vridPunktLangdA, vridPunktLangdB, friktionsKoefficient, hjul, hjulMassa, hissMassa, hissArea, malAcceleration)
    %Initierar startvärden (begynnelsevärden)
    h = y(1); %Höjd (för själva hissen)
    v = y(2); %Hastighet (positivt hastighet uppåt)
    varmeEnergi = y(3); %Värmeenergiutveckling under processen
    bromsKraft = y(4); %Bromskraften under inbromsningen
    
    if hjul == 1
        %Om bromsen ligger på det vänstra hjulet kommer repet att röra sig
        %2x dess omkrets per rotation.
        utVaxling = 1/2; 
    else
        %För det högra hjulet rör sig repet lika långt som dess omkrets
        %under en rotation, alltså behövs inte kraften skalas om.
        utVaxling = 1;
    end
    
    if v < 0
    
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
        luftMotstandsKraft = cd * rho * ((v^2)/2) * A;

        %Tyngdkraften beräknad för hela systemet.
        %I detta fall hänger hjulet på motsatt sida av hissen och därmed
        %motverkar korgens tyngdkraft
        tyngdKraft = (hissMassa - (hjulMassa/2)) * 9.82;
    
        %Kraftresultanten av systemet
        kraftTot = tyngdKraft - (luftMotstandsKraft + bromsKraftRep);
    
        %Beräkna den resulterande accelerationen skapad av bromskraften på
        %repet
        a = -kraftTot / (hissMassa + hjulMassa);
    
        %Spillvärme-effekten beräknad genom att ta bromskraften (i repet)
        %multiplicerad med hastigheten
        varmeEffekt = abs(bromsKraftRep * v);

        %Systemet som möjliggör hissen att ändra sin bromskraft beroende på
        %belastningen och siktar på att hålla en konstant acceleration
        %vilket ges av malAcceleration
        if a<malAcceleration
            dbromskraftdt = 2500 * (abs(a-malAcceleration)*2+0.25);
        elseif a>malAcceleration + 0.1
            dbromskraftdt = -1750 * (abs(a-malAcceleration)*2+0.25);
        else
            dbromskraftdt = 0;
        end

    else
        %I fallet att hissen har stannat
        v = 0;
        a = 0;
        varmeEffekt = 0;
        dbromskraftdt = 0;
    end

    %Applicera derivatorna i diff-ekvationen
    dydt = [
        v,
        a,
        varmeEffekt,
        dbromskraftdt
           ];
end