function palette_out = palette(color)

        white=[255/255,254/255,252/255];
        pearl=[251/255,252/255,247/255];
        alabaster=[254/255,250/255,241/255];
        snow=[245/255,254/255,253/255];
        ivory=[253/255,246/255,228/255];
        cream=[255/255,250/255,218/255];
        eggshell=[254/255,249/255,227/255];
        cotton=[251/255,252/255,247/255];
        chiffon=[250/255,250/255,242/255];
        salt=[247/255,239/255,236/255];
        lace=[250/255,243/255,235/255];
        coconut=[255/255,241/255,230/255];
        linen=[242/255,234/255,211/255];
        bone=[231/255,223/255,204/255];
        daisy=[255/255,255/255,255/255];
        powder=[251/255,252/255,247/255];
        frost=[236/255,252/255,252/255];
        porcelain=[255/255,254/255,252/255];
        parchment=[251/255,245/255,223/255];
        rice=[249/255,246/255,239/255];
        % tan shades
        tan=[230/255,219/255,173/255];
        beige=[236/255,221/255,154/255];
        macaroon=[248/255,224/255,118/255];
        hazelwood=[201/255,187/255,142/255];
        granola=[214/255,183/255,90/255];
        
        
        sugarcookie=[243/255,235/255,173/255];
        oat=[215/255,185/255,99/255];
        eggnog=[250/255,226/255,156/255];
        fawn=[199/255,169/255,81/255];
        sand=[215/255,185/255,99/255];
        sepia=[227/255,183/255,120/255];
        latte=[233/255,193/255,123/255];
        oyster=[220/255,215/255,160/255];
        biscotti=[227/255,197/255,101/255];
        parmesean=[253/255,233/255,146/255];
        hazelnut=[189/255,165/255,93/255];
        sandcastle=[218/255,194/255,124/255];
        buttermilk=[253/255,239/255,178/255];
        sanddollar=[236/255,232/255,185/255];
        shortbread=[251/255,231/255,144/255];
        % yellow shades
        yellow=[253/255,230/255,75/255];
        canary=[249/255,200/255,2/255];
        gold=[249/255,166/255,2/255];
        daffodil=[253/255,238/255,135/255];
        flaxen=[214/255,183/255,90/255];
        butter=[254/255,226/255,39/255];
        lemon=[239/255,253/255,95/255];
        mustard=[232/255,184/255,40/255];
        corn=[228/255,205/255,5/255];
        medallion=[227/255,177/255,4/255];
        dandelion=[253/255,206/255,42/255];
        yellowfire=[253/255,165/255,15/255];
        bumblebee=[252/255,226/255,5/255];
        banana=[252/255,244/255,163/255];
        butterscotch=[252/255,188/255,2/255];
        dijon=[194/255,146/255,0/255];
        
        blonde=[254/255,235/255,117/255];
        pineapple=[254/255,226/255,39/255];
        tuscansun=[252/255,209/255,42/255];
        % orange shades
        orange=[237/255,112/255,20/255];
        tangerine=[249/255,130/255,40/255];
        merigold=[253/255,174/255,29/255];
        cider=[181/255,103/255,39/255];
        rust=[140/255,64/255,4/255];
        ginger=[188/255,86/255,2/255];
        tiger=[252/255,107/255,2/255];
        redfire=[221/255,86/255,28/255];
        bronze=[178/255,86/255,13/255];
        cantaloupe=[252/255,161/255,114/255];
        apricot=[237/255,130/255,14/255];
        clay=[127/255,64/255,11/255];
        honey=[236/255,151/255,6/255];
        carrot=[237/255,113/255,23/255];
        squash=[201/255,92/255,10/255];
        spice=[122/255,57/255,3/255];
        marmalade=[209/255,96/255,2/255];
        amber=[137/255,49/255,1/255];
        sandstone=[214/255,113/255,41/255];
        yam=[204/255,88/255,1/255];
        % red shades
        red=[208/255,49/255,45/255];
        cherry=[153/255,15/255,2/255];
        rosered=[226/255,37/255,43/255];
        
        merlot=[84/255,31/255,27/255];
        garnet=[96/255,11/255,4/255];
        crimson=[184/255,15/255,10/255];
        ruby=[144/255,6/255,3/255];
        scarlet=[145/255,13/255,9/255];
        winered=[76/255,8/255,5/255];
        brick=[126/255,40/255,17/255];
        apple=[169/255,27/255,13/255];
        mahogany=[66/255,13/255,9/255];
        blood=[113/255,12/255,4/255];
        sangriared=[94/255,25/255,20/255];
        berryred=[121/255,24/255,18/255];
        currant=[103/255,12/255,7/255];
        blushred=[188/255,84/255,73/255];
        candy=[210/255,21/255,2/255];
        lipstick=[156/255,16/255,3/255];
        % pink shades
        pink=[246/255,154/255,205/255];
        rosepink=[252/255,148/255,173/255];
        fuscia=[252/255,70/255,170/255];
        punch=[241/255,82/255,120/255];
        blushpink=[254/255,197/255,229/255];
        watermelon=[254/255,127/255,156/255];
        flamingo=[253/255,164/255,184/255];
        rogue=[242/255,107/255,139/255];
        salmon=[253/255,171/255,159/255];
        coral=[254/255,125/255,104/255];
        peach=[251/255,148/255,131/255];
        strawberry=[252/255,77/255,74/255];
        rosewood=[160/255,66/255,66/255];
        lemonade=[251/255,187/255,203/255];
        taffy=[250/255,134/255,197/255];
        bubblegum=[253/255,92/255,168/255];
        balletslipper=[246/255,154/255,191/255];
        crepe=[242/255,184/255,198/255];
        magentapink=[225/255,21/255,132/255];
        hotpink=[255/255,22/255,149/255];
        % purple shades
        purple=[163/255,44/255,196/255];
        mauve=[122/255,74/255,136/255];
        violet=[98/255,4/255,54/255];
        boysenberry=[98/255,4/255,54/255];
        lavender=[227/255,159/255,246/255];
        plum=[96/255,26/255,54/255];
        magentapurple=[161/255,5/255,89/255];
        lilac=[182/255,96/255,205/255];
        grape=[102/255,48/255,71/255];
        periwinkle=[189/255,147/255,211/255];
        sangriapurple=[77/255,15/255,40/255];
        eggplant=[49/255,20/255,50/255];
        jam=[102/255,4/255,45/255];
        iris=[152/255,102/255,197/255];
        heather=[155/255,124/255,184/255];
        amethlyst=[164/255,94/255,229/255];
        rasin=[41/255,9/255,22/255];
        orchid=[175/255,105/255,238/255];
        mulberry=[76/255,1/255,32/255];
        winepurple=[44/255,5/255,26/255];
        % blue shades
        blue=[58/255,67/255,186/255];
        slate=[117/255,123/255,135/255];
        sky=[98/255,197/255,218/255];
        navy=[11/255,17/255,113/255];
        indigo=[40/255,30/255,93/255];
        cobalt=[19/255,56/255,189/255];
        teal=[72/255,170/255,173/255];
        ocean=[1/255,96/255,100/255];
        peacock=[1/255,45/255,54/255];
        azure=[22/255,32/255,166/255];
        cerulean=[4/255,146/255,194/255];
        lapis=[39/255,50/255,194/255];
        spruce=[44/255,62/255,76/255];
        stone=[89/255,120/255,141/255];
        aegean=[30/255,69/255,110/255];
        blueberry=[36/255,21/255,112/255];
        denim=[21/255,30/255,61/255];
        admiral=[6/255,16/255,148/255];
        sapphire=[82/255,178/255,192/255];
        artic=[130/255,237/255,253/255];
        % green shades
        green=[59/255,177/255,67/255];
        chartreuse=[172/255,252/255,56/255];
        juniper=[58/255,83/255,17/255];
        sage=[114/255,140/255,105/255];
        lime=[174/255,243/255,90/255];
        fern=[92/255,188/255,99/255];
        olive=[152/255,191/255,100/255];
        
        
        palettes.whites = [white;pearl;alabaster;snow;ivory;cream;eggshell;cotton;chiffon;salt;lace;coconut;linen;bone;daisy;powder;frost;porcelain;parchment;rice];
        palettes.tans = [tan;beige;macaroon;hazelwood;granola;fawn;oat;eggnog;fawn;sugarcookie;sand;sepia;latte;oyster;biscotti;parmesean;hazelnut;sandcastle;buttermilk;sanddollar;shortbread];
        palettes.yellows = [yellow;canary;gold;daffodil;flaxen;butter;lemon;mustard;corn;medallion;dandelion;yellowfire;bumblebee;banana;butterscotch;dijon;honey;blonde;pineapple;tuscansun];
        palettes.oranges = [orange;tangerine;merigold;cider;rust;ginger;tiger;redfire;bronze;cantaloupe;apricot;clay;honey;carrot;squash;spice;marmalade;amber;sandstone;yam];
        palettes.reds = [red;cherry;rosered;jam;merlot;garnet;crimson;ruby;scarlet;winered;brick;apple;mahogany;blood;sangriared;berryred;currant;blushred;candy;lipstick];
        palettes.pinks = [pink;rosepink;fuscia;punch;blushpink;watermelon;flamingo;rogue;salmon;coral;peach;strawberry;rosewood;lemonade;taffy;bubblegum;balletslipper;crepe;magentapink;hotpink];
        palettes.purples = [purple;mauve;violet;boysenberry;lavender;plum;magentapurple;lilac;grape;periwinkle;sangriapurple;eggplant;jam;iris;heather;amethlyst;rasin;orchid;mulberry;winepurple];
        palettes.blues = [blue;sky;navy;indigo;cobalt;teal;ocean;peacock;azure;cerulean;lapis;spruce;stone;aegean;blueberry;denim;admiral;sapphire;artic];
        %palettes.greens = [green;chartreuse;juniper;sage;lime;fern;olive;parakeet;mint;seaweed;pickle;pistachio;basil;crocodile];
        %palettes.browns = [brown;coffee;mocha;peanut;carob;hickory;wood;pecan;walnut;caramel;gingerbread;syrup;chocolate;tortilla;umber;tawny;brunette;cinnamon;penny;cedar];
        %palettes.grays = [grey;shadow;graphite;iron;pewter;cloud;silver;smoke;slate;anchor;ash;porpoise;dove;fog;flint;charcoal;pebble;lead;coin;fossil];
        %palettes.blacks = [black;ebony;crow;charcoal;midnight;ink;raven;oil;grease;onyx;pitch;soot;sable;jetblack;coal;metal;obsidian;jade;spider;leather];
    
        palette_out = palettes.(color);
        
end

