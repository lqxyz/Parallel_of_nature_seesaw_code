%% ----- Initialize and load data

clear;clc;close all;

isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
if isOctave
    % pkg install -forge statistics
    % pkg install -forge io
    pkg load io
    pkg load data-smoothing % Need to rewrite smooth
end

% turn this value to "false" if you don't care to see the figures.
showfigures = true;

dt_dir = '../data/';

% Load the WD2104 chronology; see Buizert et al. (doi: 10.5194/cp-11-153-2015) for details
% All ages are in years BP (before present, with 1950 C.E. as the reference year

load([dt_dir, 'WD2014_506modAKZ291b_v4.mat']);
WD_age = WD2014_506modAKZ291b_v4; clear WD2014_506modAKZ291b_v4;

% load WAIS Divide d18O data.
WD_18O = xlsread([dt_dir, 'WAIS_project_members_Source_Data.xlsx'], 1);
WD_18O = [mean(WD_18O(:,[2 3]),2),mean(WD_18O(:,[5 6]),2),WD_18O(:,4)];
WD_18O(:,2) = interp1(WD_age(:,1),WD_age(:,2),WD_18O(:,1));
WD_18O(WD_18O(:,3)>999998,:) = []; % Remove data points set to 999999

dummy  = xlsread([dt_dir, 'WAIS_project_members_Source_Data.xlsx'], 2);
WD_CH4 = [xlsread([dt_dir, 'WAIS_project_members_Source_Data.xlsx'], 3);
dummy(544:end,:)];
WD_CH4(:,4) = [];
WD_CH4(:,2) = interp1(WD_age(:,1),WD_age(:,3),WD_CH4(:,1));

% load NGRIP d18O data
NG_18O = load([dt_dir, 'NGRIP_d18O_GICC05modelext.txt']);
NG_18O(:,1) = NG_18O(:,1)-10; % d18O datapoint reflects midpoint of interval
NG_18O(:,2) = NG_18O(:,2) - 0.5*diff([0; NG_18O(:,2)]); %
NG_18O(:,1) = (NG_18O(:,1)-50); % Convert b2k to BP1950
NG_18O(:,1) = NG_18O(:,1)*1.0063; % For consistency with WD2014 chronology and Hulu cave
NG_18O(:,[1 2]) = NG_18O(:,[2 1]);

%% ----- load the matchpoints
% We use a number of matchpoints, which label the different DO events:
mp_label ={'YD-PB', 'BA-YD' ,'OD-BA','2','3','4','5.1','5.2','6','7','8','9','10','11','12','13','14','15.1','15.2','16.1','16.2','17.1','17.2','18'};
N_mp = numel(mp_label);

NG_mp = [1490.8891	11619	22.5
NaN NaN NaN
1604.0457	14628	15.0
1793.5106	23303	16.3
1868.9973	27728	11.7
1891.2704	28838	14.4
1919.4817	30731	10.8
1951.6574	32452	14.9
1974.4821	33687	19.0
2009.6158	35437	15.7
2069.8789	38165	13.2
2099.5006	40104	12.7
2123.9753	41408	14.4
2157.5767	43297	17.2
2221.9608	46794	20.9
2256.7293	49221	17.3
2345.3860	54164	11.3
2355.1733	54940	16.0
2366.1477	55737	26.4
2398.7139	57988	11.4
2402.2462	58210	11.6
2414.8223	59018	15.5
2420.3470	59386	15.1
2465.8393	64049	30.3];

NG_mp(:,2) = interp1(NG_18O(:,1),NG_18O(:,2),NG_mp(:,1)); % convert to WD2014 chronology
NG_mp(:,4) = NG_mp(:,3);
NG_mp(:,3) = interp1(NG_18O(:,1),NG_18O(:,3),NG_mp(:,1));


% WAIS Divide matchpoints for associated CH4 rise:
WD_mp = [1983.0692	11546.0	613	33.2
NaN NaN NaN NaN			
2259.4100	14576.3	545	27.9
2632.0761	23984.4	376	30.0
2755.7358	27754.7	408	17.9
2797.9281	29011.4	437	21.9
2848.3192	30728.1	408	26.0
2885.4378	32631.2	446	16.9
2913.0124	33874.0	465	19.0
2958.6428	35635.6	481	19.8
3021.3684	38380.7	504	33.2
3066.5170	40331.5	440	19.0
3094.1723	41643.4	441	17.6
3130.4370	43544.4	453	15.1
3195.2489	47063.8	489	15.4
3237.6552	49506.5	458	18.3
3311.0851	54480.2	491	13.4
3322.2446	55261.4	484	11.1
3329.7204	56062.8	504	13.9
3350.4424	58328.3	526	8.8
3352.5894	58551.6	519	14.2
3360.0270	59364.7	541	17.2
3363.4272	59735.4	528	22.5
3388.7327	64427.9	476	15.0];

WD_mp(:,2) = interp1(WD_age(:,1),WD_age(:,3),WD_mp(:,1));

%% ----- Isolate the individual events - NH warming

% The matices below give the edges of the chosen interval:
NG_edges = 10*[1270 1000
    NaN  NaN
    2189 1300
    2751 2304
    2861 2775
    3042 2876
    3214 3071
    3343 3224
    3468 3361
    3659 3496
    4001 3683
    4096 4021
    4231 4124
    4443 4253
    4846 4472
    4971 4879
    5513 5199
    5557 5521
    5663 5575
    NaN NaN
    5885 5702
    5955 5895
    6380 5965
    6858 6422];

CH4_edges = [2080.648	1812.710
NaN         NaN
2565.817	2108.471
2741.514	2598.827
2780.345	2749.786
2838.535	2792.535
2868.173	2845.614
2903.592	2878.600
2935.137	2907.781
2983.880	2942.338
3060.610	2989.293
3081.804	3064.461
3108.147	3085.299
3148.024	3113.490
3225.448	3153.451
3240.989	3228.469
3320.581	3259.223
3325.437	3321.556
3336.016	3327.051
NaN         NaN
3354.181	3339.482
3361.469	3356.345
3386.305	3362.654
3403.000	3387.374];
CH4_edges = interp1(WD_age(:,1),WD_age(:,3),CH4_edges);

WD_edges=[2077.004	1806.033
NaN         NaN
2552.887	2077.004
2673.064	2552.887
2768.044	2673.064
2826.920	2765.655
2859.978	2825.124
2888.932	2859.978
2925.520	2888.932
2975.811	2925.520
3053.739	2975.811
3076.775	3053.739
3102.116	3074.227
3142.221	3100.757
3220.586	3152.671
3245.056	3218.557
3321.888	3243.478
NaN         NaN
3334.887	3321.433
NaN         NaN
3352.398	3332.325
3358.874	3351.675
3385.135	3357.912
3400.513	3382.541];
WD_edges = interp1(WD_age(:,1),WD_age(:,2),WD_edges);

% Isolate the individual (contributory) events in the record:
DO_18O = NaN(length(NG_18O),N_mp);
DO_CH4 = NaN(length(WD_CH4),N_mp);
AIM_18O = NaN(length(WD_18O),N_mp);

t_DO_18O = NaN(length(NG_18O),N_mp);
t_DO_CH4 = NaN(length(WD_CH4),N_mp);
t_AIM_18O = NaN(length(WD_18O),N_mp);

t=-2000:2000;
%t = -1200:1200;
CH4lag = 56;
% Nr of datapoints averaged in fillNaN routine 
N_ave = 50;

% Align the events and interpolate to vector t
NGtimed = NaN(1,length(t));
WDtimed = NaN(1,length(t));
%CH4timed = NaN(1,length(t));

for i = 1:N_mp
    dummy1 = (NG_18O(:,2)>=(NG_edges(i,2)))&(NG_18O(:,2)<=(NG_edges(i,1)));   
    dummy11 = (NG_18O(:,2)>=(NG_edges(i,2))-2000)&(NG_18O(:,2)<=(NG_edges(i,2))+2000); 
    DO_18O(dummy1,i) = NG_18O(dummy1,3);
    t_DO_18O(dummy1,i) = NG_18O(dummy1,2);
    
    dummy = (WD_CH4(:,2)>=(CH4_edges(i,2)))&(WD_CH4(:,2)<=(CH4_edges(i,1)));   
    DO_CH4(dummy,i) = WD_CH4(dummy,3);
    t_DO_CH4(dummy,i) = WD_CH4(dummy,2);
    
    dummy2 = (WD_18O(:,2)>=(WD_edges(i,2)))&(WD_18O(:,2)<=(WD_edges(i,1)));   
    dummy22 = (WD_18O(:,2)>=(WD_edges(i,2))-2000)&(WD_18O(:,2)<=(WD_edges(i,2))+2000);   
    AIM_18O(dummy2,i) = WD_18O(dummy2,3);
    t_AIM_18O(dummy2,i) = WD_18O(dummy2,2);
    
    AIM_18O(dummy2,i) = WD_18O(dummy2,3);
    t_AIM_18O(dummy2,i) = WD_18O(dummy2,2);
    
    if i==15 || i== 22
        figure,
        set(gcf,'outerposition',get(0,'screensize'));
                
        subplot(1,2,1),hold on
        if i == 15
            plot(-WD_18O(dummy2,2)+NG_mp(i,2), smooth(AIM_18O(dummy2,i),10),'r', -NG_18O(dummy1, 2)+NG_mp(i,2), smooth(DO_18O(dummy1,i),10),'b','Linewidth',2)
            h=legend('WDC \delta^{18}O','NGRIP \delta^{18}O');
            set(h, 'FontWeight', 'Bold',...
            'FontName', 'Helvetica', 'Location', 'NorthWest','Box','off')
        end
       
        if i == 22
            plot(-WD_18O(dummy22,2)+NG_mp(i,2), smooth(WD_18O(dummy22,3),10),'r', -NG_18O(dummy11, 2)+NG_mp(i,2),smooth(NG_18O(dummy11,3),10),'b','Linewidth',2)
            h=legend('WDC \delta^{18}O','NGRIP \delta^{18}O');
            set(h, 'FontWeight', 'Bold', 'FontName', 'Helvetica', 'Location', 'NorthWest','Box','off')
            plot(-WD_18O(dummy22,2)+NG_mp(i,2), WD_18O(dummy22,3),'g', -NG_18O(dummy11, 2)+NG_mp(i,2), NG_18O(dummy11,3),'c','Linewidth',1)
        end 

        plot(-WD_18O(dummy2,2)+NG_mp(i,2), AIM_18O(dummy2,i),'g', -NG_18O(dummy1, 2)+NG_mp(i,2), DO_18O(dummy1,i),'c','Linewidth',1)

        xlim([-2000, 2000])
        xlabel('Time (year)','fontsize',20, 'FontWeight', 'Bold')
        ylabel(['WDC/NGRIP \delta^{18}O (' char(8240) ' )'],'fontsize',20, 'FontWeight', 'Bold', 'Color', 'k')
        yrange = ylim;
 
        patch([-1200, -1200, 1200, 1200],[yrange(1),yrange(2), yrange(2), yrange(1)],...
              [132,112,255]/255, 'FaceAlpha',0.2, 'EdgeColor', 'r');

        patch([0, 0, 200, 200],[yrange(1),yrange(2), yrange(2), yrange(1)],...
               'y', 'FaceAlpha',0.2, 'EdgeColor', 'None');

        subplot(1,2,2)

        NGtimed = fillNaN(interp1((NG_18O(:,2)-NG_mp(i,2)),DO_18O(:,i),-t),N_ave);
        WDtimed = fillNaN(interp1(WD_18O(:,2)-WD_mp(i,2)-CH4lag,AIM_18O(:,i),-t),N_ave);

        plot(t, smooth(WDtimed,150),'r', t, smooth(NGtimed,150),'b','Linewidth',2)
        hold on
        plot(-WD_18O(dummy2,2)+NG_mp(i,2), AIM_18O(dummy2,i),'g', -NG_18O(dummy1, 2)+NG_mp(i,2), DO_18O(dummy1,i),'c','Linewidth',1)
        
        xlim([-2000, 2000])
        xlabel('Time (year)','fontsize',20, 'FontWeight', 'Bold')
        ylabel(['WDC/NGRIP \delta^{18}O (' char(8240) ' )'],'fontsize',20, 'FontWeight', 'Bold', 'Color', 'k')
        yrange = ylim;
        patch([-1200, -1200, 1200, 1200],[yrange(1),yrange(2), yrange(2), yrange(1)],...
              [132,112,255]/255, 'FaceAlpha',0.2, 'EdgeColor', 'r');

        patch( [0, 0, 200, 200],[yrange(1),yrange(2), yrange(2), yrange(1)],...
            'y', 'FaceAlpha',0.2, 'EdgeColor', 'None');
        h=legend('WDC \delta^{18}O','NGRIP \delta^{18}O');
        set(h, 'FontWeight', 'Bold', 'FontName', 'Helvetica', 'Location', 'NorthWest','Box','off')
     
        %set(gcf, 'PaperPositionMode', 'auto')   % Use screen size
        set(gcf, 'PaperPositionMode', 'auto')   % Use screen size
        if i==15
            print -djpeg -r200 ../figs/window_warm_i15.jpeg;
        end
        if i==22
            print -djpeg -r200 ../figs/window_warm_i22.jpeg;
        end 
    end  
end
