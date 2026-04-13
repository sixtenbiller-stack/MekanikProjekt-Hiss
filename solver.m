function dydt = solver(t, y, bromsKraft, trumRadie, vridPunktLangdA, vridPunktLangdB, friktionsKoefficient, utVaxling, hjulMassa, hissMassa, hissArea)
    %Initierar startvärden (begynnelsevärden)
    h = y(1); %Höjd (för själva hissen)
    v = y(2); %Hastighet (positivt hastighet uppåt)
    varmeEnergi = y(3); %Värmeenergiutveckling under processen
    
    if v < 0
    
        kompenseradBromsKraft = bromsKraft; %bromsKraft*0.5 + bromsKraft*0.5*v^(v-5)
        kraftPrimarback = (kompenseradBromsKraft * vridPunktLangdA) / ((vridPunktLangdA/2)-friktionsKoefficient*vridPunktLangdB);
        kraftSekundarback = (kompenseradBromsKraft * vridPunktLangdA) / ((vridPunktLangdA/2)+friktionsKoefficient*vridPunktLangdB);
        
        bromsKraftRep = (kraftSekundarback + kraftSekundarback) * friktionsKoefficient * utVaxling %LÄGG TILL NÅT FÖR ATT GÖRA DEN TIDSBEROENDE
        
        cd = 1.5;
        rho = 1.2;
        A = hissArea;
        luftMotstandsKraft = cd * rho * ((v^2)/2) * A;
        tyngdKraft = (hissMassa - (hjulMassa/2)) * 9.82;
    
        kraftTot = tyngdKraft - (luftMotstandsKraft + bromsKraftRep);
    
        a = -kraftTot / (hissMassa + hjulMassa);
    
        varmeEffekt = bromsKraftRep * v;

    else
        disp("Nu står hissen still!!")
        v = 0;
        a = 0;
        varmeEffekt = 0;
    end

    dydt = [
        v,
        a,
        varmeEffekt
           ];
end