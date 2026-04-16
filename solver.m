function dydt = solver(t, y, trumRadie, vridPunktLangdA, vridPunktLangdB, friktionsKoefficient, utVaxling, hjulMassa, hissMassa, hissArea, malAcceleration)
    %Initierar startvärden (begynnelsevärden)
    h = y(1); %Höjd (för själva hissen)
    v = y(2); %Hastighet (positivt hastighet uppåt)
    varmeEnergi = y(3); %Värmeenergiutveckling under processen
    bromsKraft = y(4); %Bromskraften under inbromsningen

    
    if v < 0
    
        %bromsKraft = bromsKraft; %bromsKraft*0.5 + bromsKraft*0.5*v^(v-5)
        kraftPrimarback = (bromsKraft * vridPunktLangdA) / ((vridPunktLangdA/2)-friktionsKoefficient*vridPunktLangdB);
        kraftSekundarback = (bromsKraft * vridPunktLangdA) / ((vridPunktLangdA/2)+friktionsKoefficient*vridPunktLangdB);
        
        bromsKraftRep = (kraftSekundarback + kraftSekundarback) * friktionsKoefficient * utVaxling;
        
        cd = 1.5;
        rho = 1.2;
        A = hissArea;
        luftMotstandsKraft = cd * rho * ((v^2)/2) * A;
        tyngdKraft = (hissMassa - (hjulMassa/2)) * 9.82;
    
        kraftTot = tyngdKraft - (luftMotstandsKraft + bromsKraftRep);
    
        a = -kraftTot / (hissMassa + hjulMassa);
    
        varmeEffekt = abs(bromsKraftRep * v);

        if a<malAcceleration
            dbromskraftdt = 2500 * (abs(a-malAcceleration)*2+0.25);
        elseif a>malAcceleration + 0.1
            dbromskraftdt = -1750 * (abs(a-malAcceleration)*2+0.25);
        else
            dbromskraftdt = 0;
        end

    else
        v = 0;
        a = 0;
        varmeEffekt = 0;
        dbromskraftdt = 0;
    end

    dydt = [
        v,
        a,
        varmeEffekt,
        dbromskraftdt
           ];
end