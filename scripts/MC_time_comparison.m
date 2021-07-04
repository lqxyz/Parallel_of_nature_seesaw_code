clear;close all;clc;

tm = 33029;
tf = [13228 1205 761 616];
num = [1, 10, 16, 20];
plot(num, tf, 'k-o', 'MarkerSize', 10, 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k')
hold on
plot(1, tm,  'r-o', 'MarkerSize', 10, 'LineWidth', 3, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b')
xlabel('Number of Procs', 'FontWeight', 'Bold')
ylabel('Times(s)', 'FontWeight', 'Bold')
set(gca, 'Xtick', num)  %'Ytick', [tf(end:-1:1), tm],
text(2, tm, ['Matlab(' num2str(tm/3600,3) 'h)'], 'FontWeight', 'Bold','Color', 'b')
text(2, tf(1), ['Fortran(' num2str(tf(1)/3600,3) 'h)'], 'FontWeight', 'Bold')
text(18, tf(4)+2000, [num2str(tf(4)),'s'], 'FontWeight', 'Bold','Color', 'r')
text(9, tf(2)+2500, [num2str(tf(2)),'s'], 'FontWeight', 'Bold','Color', 'k')
text(15, tf(3)+2000, [num2str(tf(3)),'s'], 'FontWeight', 'Bold','Color', 'k')

print -djpeg  -r200  ../figs/MC_time_comparison.jpeg;
