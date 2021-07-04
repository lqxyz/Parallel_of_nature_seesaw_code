% Qun Liu 2015-06-14
% Modified for Octave on 2021-07-04

figure, 
set(gcf,'outerposition',get(0,'screensize'));

load('../data/MonteCarlo_results.mat')

subplot(2,2,1),
a = t_break_MC;
% dat = a(:,1:200);
hist(a(:), 40);
xlabel('NH lead times(years)') %, 'FontSize', 20, 'FontWeight', 'bold' )
ylabel('Frequency') %, 'FontSize', 20, 'FontWeight', 'bold' )
h = findobj(gca, 'Type', 'patch');
set(h, 'FaceColor',[0.9, 0.5, 0.5],'EdgeColor','w');
%set(gca, 'FontSize', 20)
xlim([0,400])
ylim([0,8000])
std_a = std(a(:));
mean_a = mean(a(:));
yrange = ylim;
h = text(300, yrange(2)*.8 , [num2str(floor(mean_a)), '\pm', ... %char(177), ...
    num2str(floor(2*std_a))], 'fontweight', 'bold'); %, 'FontSize', 20);
%set(h, 'Interpreter', 'Latex')


subplot(2,2,2),
a = t_break_MCc;
%dat = a(:,1:200);
hist(a(:), 40);
xlabel('NH lead times(years)') %, 'FontSize', 20, 'FontWeight', 'bold' )
ylabel('Frequency') %, 'FontSize', 20, 'FontWeight', 'bold' )
h = findobj(gca, 'Type', 'patch');
set(h, 'FaceColor',[0.9, 0.5, 0.5],'EdgeColor','w');
%set(gca, 'FontSize', 20)
xlim([0,400])
ylim([0,8000])
std_a = std(a(:));
mean_a = mean(a(:));
yrange = ylim;
h = text(300, yrange(2)*.9 , [num2str(floor(mean_a)), '\pm', ... %char(177), ...
    num2str(floor(2*std_a))], 'fontweight', 'bold'); %, 'FontSize', 20);
%set(h, 'Interpreter', 'Latex')
%print -djpeg  -r300  cool_hist2.jpeg;


subplot(2,2,3)
disp('t_MC')
fp = fopen( '../mc_result/t_MC.dat', 'rb');
a = fread(fp,[100,800],'double');
fclose(fp);

%dat = a(:,1:200);
hist(a(:), 40);
xlabel('NH lead times(years)') %, 'FontSize', 20, 'FontWeight', 'bold' )
ylabel('Frequency') %, 'FontSize', 20, 'FontWeight', 'bold' )
h = findobj(gca, 'Type', 'patch');
set(h, 'FaceColor',[0.9, 0.5, 0],'EdgeColor','w');
%set(gca, 'FontSize', 20)
xlim([0,400])
ylim([0,8000])
std_a = std(a(:));
mean_a = mean(a(:));
yrange=ylim;
h=text(300, yrange(2)*.9 , [num2str(floor(mean_a)), '\pm', ... %char(177), ...
    num2str(floor(2*std_a))], 'fontweight', 'bold'); %, 'FontSize', 20);
%set(h, 'Interpreter', 'Latex')

subplot(2,2,4),
disp('t_MCc')
fp = fopen('../mc_result/t_MCc.dat', 'rb');
a = fread(fp,[100,800],'double');
fclose(fp);

%dat = a(:,1:200);
hist(a(:), 40);
xlabel('NH lead times(years)') %, 'FontSize', 20, 'FontWeight', 'bold' )
ylabel('Frequency') %, 'FontSize', 20, 'FontWeight', 'bold' )
h = findobj(gca, 'Type', 'patch');
set(h, 'FaceColor',[0.9, 0.5, 0],'EdgeColor','w');
%set(gca, 'FontSize', 20)
xlim([0,400])
ylim([0,8000])
std_a = std(a(:));
mean_a = mean(a(:));
yrange = ylim;
h = text(300, yrange(2)*.9 , [num2str(floor(mean_a)), '\pm', ... % char(177), ...
    num2str(floor(2*std_a))], 'fontweight', 'bold'); %, 'FontSize', 20);

set(gcf, 'PaperPositionMode', 'auto')   % Use screen size
print -djpeg  -r200  ../figs/FourHist.jpeg;
