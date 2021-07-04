% All ages are in years BP (before present, with 1950 C.E. as the reference year
clear; clc; close all;

isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
if isOctave
    % pkg install -forge io
    % pkg install -forge data-smoothing
    pkg load io
    pkg load data-smoothing
end

dt_dir = '../data/';

load([dt_dir, 'WD2014_506modAKZ291b_v4.mat']);
WD_age = WD2014_506modAKZ291b_v4; clear WD2014_506modAKZ291b_v4;

% load WAIS Divide d18O data.
WD_18O = xlsread([dt_dir, 'WAIS_project_members_Source_Data.xlsx'], 1);
WD_18O = [mean(WD_18O(:,[2 3]),2),mean(WD_18O(:,[5 6]),2),WD_18O(:,4)];
WD_18O(:,2) = interp1(WD_age(:,1),WD_age(:,2),WD_18O(:,1));
WD_18O(WD_18O(:,3)>999998,:) = []; % Remove data points set to 999999
%save WD.mat WD_18O

% load NGRIP d18O data
NG_18O = load([dt_dir, 'NGRIP_d18O_GICC05modelext.txt']);
NG_18O(:,1) = NG_18O(:,1)-10; % d18O datapoint reflects midpoint of interval
NG_18O(:,2) = NG_18O(:,2) - 0.5*diff([0; NG_18O(:,2)]); %
NG_18O(:,1) = (NG_18O(:,1)-50); % Convert b2k to BP1950
NG_18O(:,1) = NG_18O(:,1)*1.0063; % For consistency with WD2014 chronology and Hulu cave
NG_18O(:,[1 2]) = NG_18O(:,[2 1]);

N = 15;

figure;
set(gcf,'outerposition', get(0, 'screensize'));

h1=subplot(2,1,1);
t = WD_18O(:,2);
d18o = WD_18O(:,3);
flag = t>20000 & t<70000;
plot(t(flag), d18o(flag),'c', 'linewidth', 0.5)
hold on
if isOctave
    [yh, lambda] = regdatasmooth(t(flag), d18o(flag));
    plot(t(flag), yh, 'b', 'Linewidth', 1.5);
else
    plot(t(flag), smooth(d18o(flag), N), 'b', 'Linewidth', 1.5);
end

ylabel(['WDC \delta^{18}O (' char(8240) ' )'], 'Color', 'b') %, 'Interpreter','tex')
% xtick = get(h1, 'Xtick')/1000;
% xtick
% for i=1:length(xtick)
%     xticklabel{i} = num2str(xtick(i));
% end
set(h1, 'XtickLabel',  {'20','25','30','35','40','45','50','55','60','65','70'})
text(69000, -36.8, '(a)')
set(h1, 'XDir', 'reverse')

h2 = subplot(2,1,2);
ng18o = NG_18O(:,3);
t = NG_18O(:,2);
flag = t > 20000 & t < 70000;
plot(t(flag), ng18o(flag), 'g')
hold on
%plot(t(flag), smooth(ng18o(flag),N), 'r')
if isOctave
    [yh, lambda] = regdatasmooth(t(flag), ng18o(flag));
    plot(t(flag), yh, 'b', 'Linewidth', 1.5);
else
    plot(t(flag), smooth(ng18o(flag), N), 'b', 'Linewidth', 1.5);
end
set(h2, 'XDir', 'reverse')
xlabel('WD2014 age (kyr BP)')
ylabel(['NGRIP \delta^{18}O (' char(8240) ' )'], 'Color', 'r')

set(gca)
xtick = get(h2, 'Xtick')/1000;
for i=1:length(xtick)
    xticklabel{i} = num2str(xtick(i));
end
set(h2, 'XtickLabel', xticklabel)
text(69000, -36.8, '(b)')
set(gcf, 'PaperPositionMode', 'auto')   % Use screen size

print -djpeg -r200 ../figs/WD_NGRIP_d18O_time_series.jpeg;
