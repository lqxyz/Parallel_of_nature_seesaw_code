% This script is a supplement to the paper:
%
% WAIS Divide Project Members: Precise interpolar phasing of abrupt climate
% change during the last ice age, Nature (2015)
%
% The code performs the data stacking and the Monte Carlo sensitivity study
% as described in that work. The MC study is computationally intenstive,
% and is not run by default. To run it, remove the "break" command on line 521.
%
% In case of questions please contact:
%
% Christo Buizert
% E: buizertc@science.oregonstate.edu
% T: +1 (541)-737-1209
%
% Thanks for your interest in this work.
%
% Christo Buizert, Corvallis Oregon, February 13, 2015


%% ----- Initialize and load data

clear; %close all; format compact;

isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
if isOctave
    % For install
    % pkg install -forge statistics
    % pkg install -forge io
    pkg load io
    pkg load statistics % For Octave
end

dt_dir = '../data/'

% turn this value to "false" if you don't care to see the figures.
showfigures = true;

% Load the WD2104 chronology; see Buizert et al. (doi: 10.5194/cp-11-153-2015) for details
% All ages are in years BP (before present, with 1950 C.E. as the reference year
load([dt_dir, 'WD2014_506modAKZ291b_v4.mat']);
WD_age = WD2014_506modAKZ291b_v4; clear WD2014_506modAKZ291b_v4;

% load WAIS Divide d18O data.
WD_18O = xlsread([dt_dir, 'WAIS_project_members_Source_Data.xlsx'],1);
WD_18O = [mean(WD_18O(:,[2 3]),2),mean(WD_18O(:,[5 6]),2),WD_18O(:,4)];
WD_18O(:,2) = interp1(WD_age(:,1),WD_age(:,2),WD_18O(:,1));
WD_18O(WD_18O(:,3)>999998,:) = []; % Remove data points set to 999999

dummy  = xlsread([dt_dir, 'WAIS_project_members_Source_Data.xlsx'],2);
WD_CH4 = [xlsread([dt_dir, 'WAIS_project_members_Source_Data.xlsx'],3);dummy(544:end,:)];
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

% See Buizert et al. (2015) for details on finding the midpoints in the
% data series. Values used below can be found in Table 1 and Table 2 of
% that work.

% NGRIP matchpoints for d18O warming transitions:
% columns are depth, GICC05 age, and age uncertainty
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

% NGRIP matchpoints for d18O cooling transitions:
% columns are depth, GICC05 age, and age uncertainty
NG_cmp = [NaN NaN NaN
1524.2104	12775.2	81.1
NaN NaN NaN	
NaN	NaN NaN	
1861.9104	27497.9	51.9
1882.5891	28548.1	16.9
1916.4501	30571.3	69.8
1939.7088	31991.8	12.7
1964.5235	33323.0	36.8
1990.5826	34703.0	13.1
2027.4302	36570.7	21.4
2095.5082	39905.1	42.0
2112.5313	40917.4	43.9
2135.6574	42231.2	27.1
2171.1711	44307.6	41.2
2242.8546	48440.0	27.1
2261.4897	49551.9	19.5
2353.6644	54849.8	18.2
2359.9226	55369.2	54.6
2375.8778	56555.3	49.2
2400.5617	58123.5	15.2
2406.5200	58543.9	35.2
2417.7683	59257.4	17.8
2462.0723	63810.2	14.4];

NG_cmp(:,2) = interp1(NG_18O(:,1),NG_18O(:,2),NG_cmp(:,1)); % convert to WD2014 ages
NG_cmp(:,4) = NG_cmp(:,3);
NG_cmp(:,3) = interp1(NG_18O(:,1),NG_18O(:,3),NG_cmp(:,1));

WD_cmp = [NaN   NaN     NaN     NaN
2096.6282	12875	572	52.4
NaN   NaN     NaN     NaN
NaN   NaN     NaN     NaN
2747.2534	27679	415	40.5
2787.9585	28864	424	60.6
2845.4221	30702	405	51.0
2875.8550	32103	454	68.2
2905.5804	33518	455	56.7
2939.0671	34835	485	53.5
2986.5654	36707	476	32.0
3063.7742	40149	442	21.7
3083.8925	41074	446	45.7
3110.7586	42450	429	67.6
3149.8880	44532	441	46.4
3226.9102	48795	420	17.3
3243.1086	49858	443	77.1
3321.1532	55146	481	15.2
3326.4670	55685	495	44.8
3337.9865	57036	506	83.9
3351.7845	58465	535	8.9
3355.5402	58859	526	60.6
3362.2545	59586	548	24.3
3387.2849	64076	491	32.2];

WD_cmp(:,2) = interp1(WD_age(:,1),WD_age(:,3),WD_cmp(:,1));

if showfigures
    % plot NGRIP d18O with matchpoints
    figure
    plot(NG_18O(:,2)/1000, NG_18O(:,3),'linewidth',0.5,'color',[0 0.7 1])
    hold on
    plot(NG_18O(:,2)/1000, smooth(NG_18O(:,3),5),'linewidth',1,'color',[0 0 0.9])
    xlim([0 67])
    xlabel('WD2014 Age (ka BP)','fontsize',12)
    ylabel(['NGRIP \delta^{18}O (', char(8240),')'],'fontsize',12)
    plot(NG_mp(:,2)/1000, NG_mp(:,3),'o','color',[0 0 0.9],'Markersize',5,'markerfacecolor','w')
    plot(NG_cmp(:,2)/1000, NG_cmp(:,3),'o','color',[0.9 0 0],'Markersize',5,'markerfacecolor','w')

    % plot WAIS CH 4 data with matchpoints
    figure
    plot(WD_CH4(:,2)/1000,WD_CH4(:,3),'linewidth',1,'color',[0 0.7 0])
    hold on
    plot(WD_mp(:,2)/1000, WD_mp(:,3),'o','color',[0 0 0.9],'Markersize',5,'markerfacecolor','w')
    plot(WD_cmp(:,2)/1000, WD_cmp(:,3),'o','color',[0.9 0 0],'Markersize',5,'markerfacecolor','w')
    ylim([300 800])
    xlim([0 67])
    xlabel('WD2014 Age (ka BP)','fontsize',12)
    ylabel('WDC CH_4 (ppb)','fontsize',12)
    text(15, 700,'NOTE: This is the WDC discrete CH_4 data set.','color','r')
    text(15, 680,'Continuous CH_4 data were used to determine matchpoints.','color','r')
    text(15, 660,'Continuous data will be published as Rhodes et al.: ','color','r')
    text(15, 640,'Enhanced tropical methane production in response to','color','r')
    text(15, 620, 'iceberg discharge in the North Atlantic. in review (2015).','color','r')

end

%% ----- Isolate the individual events - NH warming

% The next step is to isolate the individual events from the long records.
% As outlined in the Methods section, we crop the contributory events to
% avoid overlap. See Extended Data Fig. 3.

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

for i = 1:N_mp
    dummy = (NG_18O(:,2)>=(NG_edges(i,2)))&(NG_18O(:,2)<=(NG_edges(i,1)));
    DO_18O(dummy,i) = NG_18O(dummy,3);
    dummy = (WD_CH4(:,2)>=(CH4_edges(i,2)))&(WD_CH4(:,2)<=(CH4_edges(i,1)));
    DO_CH4(dummy,i) = WD_CH4(dummy,3);
    dummy = (WD_18O(:,2)>=(WD_edges(i,2)))&(WD_18O(:,2)<=(WD_edges(i,1)));
    AIM_18O(dummy,i) = WD_18O(dummy,3);
end

%% ----- Isolate the individual events - NH cooling

% Same as above, but now for the NH cooling events
% The matices below give the edges of the chosen interval:
NG_edges = 10*[NaN NaN
         1460  1180
       NaN NaN
       NaN NaN
       2785 2361
       2896 2798
       3091 2912
       3260 3109
       3385 3272
       3560 3403
       3834 3572
       4033 3854
       4164 4043
       4353 4176
       4701 4369
       4949 4730
       5416 4957
       5527 5454
       5603 5533
       5831 5617
       5857 5837
       5935 5861
       5973 5943
       6442 6000];

CH4_edges = [NaN        NaN
2250.539	1998.120
NaN        NaN
NaN        NaN
2754.425	2641.789
2796.652	2757.977
2847.553	2800.044
2883.823	2852.642
2912.402	2887.688
2957.433	2914.819
3019.428	2961.811
3065.772	3023.263
3093.640	3068.205
3129.654	3096.663
3192.791	3131.268
3236.927	3197.673
3310.623	3238.355
3322.126	3312.153
3329.485	3322.881
3350.056	3330.087
3352.421	3350.701
3359.757	3353.161
3363.197	3360.357
3388.537	3365.840];
CH4_edges = interp1(WD_age(:,1),WD_age(:,3),CH4_edges);

WD_edges=[NaN	    NaN
2216.967	1987.161
NaN	    NaN
2605.426	2222.436
2741.587	2694.681
2787.510	2744.304
2840.475	2797.167
2873.716	2846.930
2901.460	2878.375
2947.954	2901.006
3011.833	2960.165
NaN	    NaN
3085.068	3021.564
3121.210	3091.116
3185.643	3123.663
3231.001	3187.312
3303.479	3231.001
NaN	    NaN
3325.400	3303.479
3348.361	3325.400
NaN	    NaN
3356.345	3349.189
3360.381	3356.345
3387.816	3360.381];
WD_edges = interp1(WD_age(:,1),WD_age(:,2),WD_edges);


% Isolate the individual (contributory) events in the record:
DOc_18O = NaN(length(NG_18O),N_mp);
DOc_CH4 = NaN(length(WD_CH4),N_mp);
AIMc_18O = NaN(length(WD_18O),N_mp);

for i = 1:N_mp
    dummy = (NG_18O(:,2)>=(NG_edges(i,2)))&(NG_18O(:,2)<=(NG_edges(i,1)));
    DOc_18O(dummy,i) = NG_18O(dummy,3);
    dummy = (WD_CH4(:,2)>=(CH4_edges(i,2)))&(WD_CH4(:,2)<=(CH4_edges(i,1)));
    DOc_CH4(dummy,i) = WD_CH4(dummy,3);
    dummy = (WD_18O(:,2)>=(WD_edges(i,2)))&(WD_18O(:,2)<=(WD_edges(i,1)));
    AIMc_18O(dummy,i) = WD_18O(dummy,3);
end

clear *edges dummy

%% ------- Stacking - NH warming

warning('off','MATLAB:interp1:NaNinY')

% set the CH4 lag. We use 56 years following Baumgartner et al. 2014
CH4lag = 56;

% What would you like to stack? All events, major or minor events?

% We omit DO 2 from the stacking as the CH4 rise is not coincident with the
% Greenland temperature rise, as is clear from e.g. GISP2 d15N and CH4 data.
% This CH4 rise is likely to reflect southern sourced CH4 during the
% Heinrich stadial, as is also obsevered during HS4 and HS5; i.e. DO 8 and
% DO 12 are preceded by increased CH4 concentrations also.

allDO = 5:24;
bigDO = [6 11 15 17 23];
smallDO = [5 7:10 12:14 16 18:22 24];

ofinterest = allDO;  % set this value to either allDO, bigDO or smallDO; that one will be stacked and plotted

% time vector used for interpolation:
t = -1200:1200;

% Nr of datapoints averaged in fillNaN routine
N_ave = 50;

% Align the events and interpolate to vector t
NGtimed = NaN(N_mp,length(t));
WDtimed = NaN(N_mp,length(t));
CH4timed = NaN(N_mp,length(t));

for i = [1 3 allDO]
    NGtimed(i,:) = fillNaN(interp1((NG_18O(:,2)-NG_mp(i,2)),DO_18O(:,i),-t) - NG_mp(i,3),N_ave);
    CH4timed(i,:) = fillNaN(interp1(WD_CH4(:,2)-WD_mp(i,2)-CH4lag,DO_CH4(:,i),-t)-WD_mp(i,3),N_ave);
    WDtimed(i,:) = fillNaN(interp1(WD_18O(:,2)-WD_mp(i,2)-CH4lag,AIM_18O(:,i),-t),N_ave);
end

% Average over the different events:
WDstack   = nanmean(WDtimed(ofinterest,:));
NGstack   = nanmean(NGtimed(ofinterest,:));
CH4stack  = nanmean(CH4timed(ofinterest,:));

% Find the breakpoint in the d18O composite
[t_break] = WDC_breakpoint(t,WDstack, 50:20:350,1);
[t_break, fit_curve] = WDC_breakpoint(t,WDstack, round(t_break)+(-100:2:100),2);


%% ----- Stacking - NH cooling

% these are the DO events we'll be stacking:
allDOc = 5:24;

% The WD2014 chronology is not fully synchronized at the NH cooling events.
% For the timing of the DO events we take the mean of the timing from
% NGRIP, and the timing from the WDC CH4 record (synchonized part only):
mean_cmp(:,1) = 0.5*( (WD_cmp(:,2)+25) + NG_cmp(:,2) ); % greenland timing; WD2014 assumes 25 years CH4 lag
mean_cmp(:,2) = 0.5*( WD_cmp(:,2) + (NG_cmp(:,2)-25) );
% for the first 7 events, the WD014 is based on layer-counting; therefore
% we simply use the midpoints as determined at each of the records.
mean_cmp(1:7,1) = NG_cmp(1:7,2);
mean_cmp(1:7,2) = WD_cmp(1:7,2);

% Align the events and interpolate to vector t
NGtimedc = NaN(N_mp,length(t));
WDtimedc = NaN(N_mp,length(t));
CH4timedc = NaN(N_mp,length(t));

for teller = allDOc
    NGtimedc(teller,:) = fillNaN(interp1((NG_18O(:,2)-mean_cmp(teller,1)),DOc_18O(:,teller),-t) - NG_cmp(teller,3),N_ave);
    CH4timedc(teller,:) = fillNaN(interp1(WD_CH4(:,2)-mean_cmp(teller,2)-CH4lag,DOc_CH4(:,teller),-t)-WD_cmp(teller,3),N_ave);
    WDtimedc(teller,:) = fillNaN(interp1(WD_18O(:,2)-mean_cmp(teller,2)-CH4lag,AIMc_18O(:,teller),-t),N_ave);

end

% Average over the different events:
WDstackc = nanmean(WDtimedc(ofinterest,:));
NGstackc = nanmean(NGtimedc(ofinterest,:));
CH4stackc = nanmean(CH4timedc(ofinterest,:));

% Find the breakpoint in the d18O composite
[t_breakc] = WDC_breakpoint(t,WDstackc, 50:20:350,1);
[t_breakc, fit_curvec] = WDC_breakpoint(t,WDstackc, round(t_breakc)+(-100:2:100),2);

% plot the stacks:
if showfigures
    figure;
    plot(t, NGstack/(max(NGstack)-min(NGstack))+1.1,'linewidth',1,'color',[0 0.2 0.9])
    hold on
    plot(t, CH4stack/(max(CH4stack)-min(CH4stack))+1.1,'linewidth',1,'color',[0 0.8 0])
    xlim([-600 800])
    plot(t, (WDstack-mean(WDstack))/(max(WDstack)-min(WDstack)),'linewidth',0.8,'color',[1 0.6 0])
    plot(t, (fit_curve-mean(WDstack))/(max(WDstack)-min(WDstack)),'linewidth',1.2,'color',[0.9 0.4 0])
    xlabel('Time (years)','fontsize',12)
    ylabel('Normalized signal (years)','fontsize',12)
    ylim([-0.4 1.7])

    figure;
    plot(t, NGstackc/(max(NGstackc)-min(NGstackc))+0.8,'linewidth',1,'color',[0 0.2 0.9])
    hold on
    plot(t, CH4stackc/(max(CH4stackc)-min(CH4stackc))+0.8,'linewidth',1,'color',[0 0.8 0])
    xlim([-600 800])
    plot(t, (WDstackc-mean(WDstackc))/(max(WDstackc)-min(WDstackc)),'linewidth',0.8,'color',[1 0.6 0])
    plot(t, (fit_curvec-mean(WDstackc))/(max(WDstackc)-min(WDstackc)),'linewidth',1.2,'color',[0.9 0.4 0])
    xlabel('Time (years)','fontsize',12)
    ylabel('Normalized signal (years)','fontsize',12)
    ylim([-0.7 1.4])
end

% Remove the "break" command below if you want to run the monte carlo
% simulations also. Be warned that the MC simulations make take several
% hours to run (on my laptop at least).
%% break
%% ------ Now do the Monte Carlo simulations

% Load the chronologies.
% Note that in the paper we use 1000 different Delta-age functions,
% combined with 4 separate depth-interpolation schemes (Buizert et al.
% 2015). The file containing all chronologies is too large for the Nature
% supplement, and we have reduced this to 200 Delta-age functions.
% Please contact buizertc@science.oregonstate.edu for the complete files.

load([dt_dir, 'WDC_4x200_chronologies.mat']);

warning('off','MATLAB:interp1:NaNinY')

if showfigures
    figure;
end

% How many
N_Da = 800; % 800 gives you all the Delta-age scenarios
N_MC = 100; % number of simulations per delta-age scenario

t_break_MC = zeros(N_Da,N_MC);
t_break_MCc = zeros(N_Da,N_MC);

for teller = allDO
    NGtimed(teller,:) = fillNaN(interp1((NG_18O(:,2)-NG_mp(teller,2)),DO_18O(:,teller),-t) - NG_mp(teller,3),N_ave);
end

tic
disp('----- Monte Carlo analysis started -----')
for loop_Da = 1:N_Da

    i = floor((loop_Da-1)/200)+1;  % what interpolation scheme?
    j = rem(loop_Da-1,200)+1;      % what Dage realization?

    % Find the new WAIS Divide chronology:
    Ages_18O  = interp1([3405,eval(['z_sens',num2str(i)]),0],[68000, eval(['SP',num2str(i),'_ice(',num2str(j),',:)']),-57],WD_18O(:,1));
    WD_mpnew  = interp1([3405,eval(['z_sens',num2str(i)]),0],[68000, eval(['SP',num2str(i),'_gas(',num2str(j),',:)']),-57],WD_mp(:,1));
    WD_cmpnew = interp1([3405,eval(['z_sens',num2str(i)]),0],[68000, eval(['SP',num2str(i),'_gas(',num2str(j),',:)']),-57],WD_cmp(:,1));


    % WD cooling timing uses the average of WD and NGRIP; see explanation above
    mean_cmp(:,1) = 0.5*((WD_cmpnew+25) + NG_cmp(:,2));
    mean_cmp(:,2) = 0.5*(WD_cmpnew + (NG_cmp(:,2)-25));
    mean_cmp(1:7,1) = NG_cmp(1:7,2);
    mean_cmp(1:7,2) = WD_cmpnew(1:7);

    cmp_mismatch = (WD_cmpnew+25-NG_cmp(:,2)); % note: a 25 year CH4 lag is assumed in the WD2014 chronology (Buizert et al. 2015)
    cmp_mismatch(1:7) = nanmean(abs(cmp_mismatch(8:end))); % for the first 7 entries the chronologies are independently layer counted.

    % Redo the sampling on the new chronology
    for teller = allDO;
        WDtimed(teller,:)  = fillNaN(interp1(Ages_18O-WD_mpnew(teller)-CH4lag,AIM_18O(:,teller),-t),N_ave);
        WDtimedc(teller,:) = fillNaN(interp1(Ages_18O-mean_cmp(teller,2)-CH4lag,AIMc_18O(:,teller),-t),N_ave);
    end

    % For the tested WDC chronology, try N_MC different random
    % re-alignments of the individual events:
    for teller = 1:N_MC

        % The variable "MC_shuffler" alters the timing of individual events
        % within their uncertainty estimate.

        % ------------- warming case first

        % non-systematic errors:    (positive values of MC_shuffler DELAY WD cooling)
        % error in:   CH4 lag               midpoint NG                    midpoint WDC
        MC_shuffler = 0.5*27*randn(N_mp,1)+ 0.5*NG_mp(:,4).*randn(N_mp,1)+ 0.5*WD_mp(:,4).*randn(N_mp,1);
        % systematic errors:
        % error in:                                          CH4 lag:       Breakfit
        MC_shuffler = MC_shuffler + ones(size(MC_shuffler))*(0.5*27*randn + 0.5*50.8*randn);
        MC_shuffler = round(MC_shuffler);

        % If N_MC equals 1, we just test the original alignment
        if N_MC==1
           MC_shuffler = zeros(size(MC_shuffler));
        end

        dummy = NaN(size(WDtimed));
        for i = 1:N_mp
            if MC_shuffler(i) == 0;
                dummy(i,:) = WDtimed(i,:);
            elseif MC_shuffler(i) >0;
                dummy(i,(MC_shuffler(i)+1):2401)= WDtimed(i,1:(2401-MC_shuffler(i)));
            elseif MC_shuffler(i) <0;
                dummy(i,1:(2401+MC_shuffler(i)))= WDtimed(i,(1-MC_shuffler(i)):2401);
            end
        end

        % make the composite:
        WDstack = nanmean(dummy(allDO,:));

        % find the breakpoint:
        [t_break] = WDC_breakpoint(t,WDstack, 50:20:350,1);
        [t_break, fit_curve] = WDC_breakpoint(t,WDstack, round(t_break)+(-100:2:100),2);

        t_break_MC(loop_Da,teller) = t_break;


        % ------------- cooling case second

        % non-systematic errors:    (positive values of MC_shuffler DELAY WD cooling)
        % error in:   CH4 lag (of 2 neighbours)           midpoint NG                     midpoint WDC
        MC_shuffler = round(0.5*27*sqrt(2)*randn(N_mp,1)+ 0.5*NG_cmp(:,4).*randn(N_mp,1)+ 0.5*WD_cmp(:,4).*randn(N_mp,1)+ 0.5*cmp_mismatch.*randn(N_mp,1));
        % systematic errors:
        % error in:                                          CH4 lag:       Breakfit
        MC_shuffler = MC_shuffler + ones(size(MC_shuffler))*(0.5*27*randn + 0.5*50.8*randn);
        MC_shuffler = round(MC_shuffler);

        if N_MC == 1
           MC_shuffler = zeros(size(MC_shuffler));
        end

        dummy = NaN(size(WDtimedc));
        for i = 1:N_mp
            if MC_shuffler(i) == 0;
                dummy(i,:) = WDtimedc(i,:);
            elseif MC_shuffler(i) >0;
                dummy(i,(MC_shuffler(i)+1):2401)= WDtimedc(i,1:(2401-MC_shuffler(i)));
            elseif MC_shuffler(i) <0;
                dummy(i,1:(2401+MC_shuffler(i)))= WDtimedc(i,(1-MC_shuffler(i)):2401);
            end
        end


        % make the composite
        WDstackc = nanmean(dummy(allDOc,:));

        % Find the breakpoint in the d18O composite
        [t_breakc] = WDC_breakpoint(t,WDstackc, 50:20:350,1);
        [t_breakc, fit_curvec] = WDC_breakpoint(t,WDstackc, round(t_breakc)+(-100:2:100),2);

        t_break_MCc(loop_Da,teller) = t_breakc;

        % look the plots of the stacks; be warned, this slows things
        % down a lot

        if showfigures
            plot(t,WDstack,'b')
            hold on
            plot(t,fit_curve,'r')
            plot(t,WDstackc+1.5,'k')
            plot(t,fit_curvec+1.5,'g')
            xlim([-600 700])
            ylim([-40 -37.5])
            xlabel('Time (years)','fontsize',12)
            ylabel(['WDC \delta^{18}O (',char(8240),')'],'fontsize',12)
            title(['Chronology nr. ',num2str(loop_Da),', iteration nr. ',num2str(teller)],'fontsize',12);
            hold off

            pause(.000001); % this forces the graph to update
        end

    end
    disp(['Chronology nr ',num2str(loop_Da),'. W: ',num2str(round(mean(t_break_MC(loop_Da,:)))),' +/- ',num2str(round(2*std(t_break_MC(loop_Da,:)))),' and C: ',num2str(round(mean(t_break_MCc(loop_Da,:)))),' +/- ',num2str(round(2*std(t_break_MCc(loop_Da,:))))]); toc
    if rem(loop_Da,10)==0 % save some of the preliminary results, if desired

%         save MonteCarlo_results t_break_MC t_break_MCc
    end
end

% save MonteCarlo_results t_break_MC t_break_MCc
