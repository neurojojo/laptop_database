% Queried searches and figures - Jan 22 %

colors = {'paleblues';'blueolives';'tans'}; 

query = {{'Gi1 D2 ins4a','not quinpirole','not sulpiride'};...
         {'Gi1 D2 ins4a', 'quinpirole'};...
         {'Gi1 D2 ins4a','Sulpiride'}};

t = searchObj( rc_obj, query, 'sorting', [1,3,2,4,6,5,7] )
t.setcolors(colors);
plot(t)

saveas(gcf,'c:\\laptop_database\\new_figures_jan23\\figure1.svg')

%%

colors = {'paleblues';'reds'}; 
query = {{'2400 ng'};...
        {'Gi','not D2','not Lat'}};


t = searchObj( rc_obj, query )
t.setcolors(colors);
plot(t)

saveas(gcf,'c:\\laptop_database\\new_figures_jan23\\figure2.svg')

%%

colors = {'oranges';'magentas'}; 
query = {{'D2','1200 ng', 'no treat', 'not PTXR'};
        {'PTXR','1200 ng', 'no treat'}};

t = searchObj( rc_obj, query )
t.setcolors(colors);
plot(t)

saveas(gcf,'c:\\laptop_database\\new_figures_jan23\\figure3.svg')
%%

query = {{'Gi','D2','not ins4a', 'no treat'};...
         {'Myr'};...
         {'Gi1 D2 Quinpirole'};...
         {'Gi1 D2 PTXR Quinpirole'}};
colors = {'greens';'pinks';'paleblues';'blues'}

t = searchObj( rc_obj, query )
t.setcolors(colors);
plot(t)

saveas(gcf,'c:\\laptop_database\\new_figures_jan23\\figure4.svg')
%%

colors = {'grays';'tans';'greens';'pinks'}
query = { {'Gi','not D2','not ins4a', 'no treat'};...
          {'Gi','not D2','not ins4a', 'quinpirole'};...
          {'Gi','D2','2400'};...
          {'Myr'} };
      
t = searchObj( rc_obj, query )
t.setcolors(colors);
plot(t)

saveas(gcf,'c:\\laptop_database\\new_figures_jan23\\figure5.svg')
%%

colors = {'greens';'reds';'paleblues'}
query = { {'Gi','D2','2400','not quinpirole','not sulpiride'};...
            {'Gi','D2','2400','Quinpirole'};...
          {'ins4a','1200'} };
      
t = searchObj( rc_obj, query )
t.setcolors(colors);
plot(t)


saveas(gcf,'c:\\laptop_database\\new_figures_jan23\\figure6.svg')

%%

