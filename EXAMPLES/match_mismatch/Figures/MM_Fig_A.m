disp('Fig_A, models A - F');
clear

figure(1); clf
set(gcf, 'position', [875   792   600   540])

lags_range=[-1 2]; % s, common to all plots
ylimits=[-.1 .4]; % common to all plots

load ../tmp/Fig_A_data % loads   data_A data_B data_C data_E data_F data_all shifts2 sr         


subplot 331
h=plot(data_A.lags,data_A.noxval(:,data_A.iBestChannel), 'k'); h.Color=[1 1 1]*.8;
hold on
plot(data_A.lags,abs(data_A.noxval(:,data_A.iBestChannel)), 'k');
line(lags_range, [0 0], 'color', 'k', 'linewidth', 0.25); 
line([0 0], [-1 1], 'color', 'k', 'linewidth', 0.25); 
xlim(lags_range); ylim(ylimits);
set(gca,'xgrid','on', 'ygrid','on')
%xlabel('shift (s)'); 
ylabel('correlation');
title('Model A')

% all channels as raster plot
subplot 337
nt_imagescc(data_A.noxval(find(data_A.lags>lags_range(1) & data_A.lags<lags_range(2)),:)'); 
h=colorbar('location', 'eastoutside'); set(get(h,'ylabel'),'string','correlation');
set(h,'ytick',[-.1 0 .1])
xlabel('shift (s)'); ylabel('channel');
set(gca,'xticklabel',linspace(lags_range(1),lags_range(2),4), 'xtick', linspace(1, size(data_A.noxval,1),4));

subplot 332
h=plot(data_B.shifts/sr, data_B.xval, 'k', 'linewidth', 2); % h.Color=[1 1 1]*.8;
hold on; 
plot(data_B.shifts/sr,  data_B.noxval, 'k'); drawnow
ylim(ylimits);
set(gca,'xgrid','on', 'ygrid','on')
line(lags_range, [0 0], 'color', 'k', 'linewidth', 0.25); 
line([0 0], [-1 1], 'color', 'k', 'linewidth', 0.25); 
title('Model B');

subplot 333
plot(data_C.shifts/sr, data_C.noxval, 'k');
hold on;
plot(data_C.shifts/sr, data_C.xval, 'k', 'linewidth',2);
set(gca,'xgrid','on', 'ygrid','on')
% xlabel('shift (s)'); 
ylabel('correlation');
ylim(ylimits);
line(lags_range, [0 0], 'color', 'k', 'linewidth', 0.25); 
line([0 0], [-1 1], 'color', 'k', 'linewidth', 0.25); 
title('Model C');

subplot 338
% topography
nt_topoplot('biosemi64.lay',data_C.c); 
h=colorbar('location', 'southoutside'); set(get(h,'xlabel'),'string','correlation');


yl=[-.1 .4];
lags_range=[-1 2];

subplot 334
plot(data_D.shifts/sr, data_D.noxval(:,2:end)); % {2} is crossvalidated
hold on
plot(data_D.shifts/sr, data_D.xval(:,1), 'k', 'linewidth',2);
set(gca,'xgrid','on', 'ygrid','on')
xlabel('shift (s)'); ylabel('correlation');
ylim(ylimits);
line(lags_range, [0 0], 'color', 'k', 'linewidth', 0.25); 
line([0 0], [-1 1], 'color', 'k', 'linewidth', 0.25); 
title('Model D');
xlabel('shift (s)');

subplot 335
%plot(shifts/sr, RRRR{1}, 'k');
hold on;
plot(data_E.shifts/sr, data_E.xval, 'k', 'linewidth',2);
set(gca,'xgrid','on', 'ygrid','on')
xlabel('shift (s)'); ylabel('correlation');
ylim(ylimits);
line(lags_range, [0 0], 'color', 'k', 'linewidth', 0.25); 
line([0 0], [-1 1], 'color', 'k', 'linewidth', 0.25); 
title('Model E');

subplot 336
plot(data_F.shifts/sr, data_F.xval(:,2:end)); hold on
plot(data_F.shifts/sr, data_F.xval(:,1), 'k', 'linewidth',2);
set(gca,'xgrid','on', 'ygrid','on')
xlabel('shift (s)'); ylabel('correlation');
ylim(ylimits);
line(lags_range, [0 0], 'color', 'k', 'linewidth', 0.25); 
line([0 0], [-1 1], 'color', 'k', 'linewidth', 0.25); 
title('Model F');
xlabel('shift (s)');

% Wilcoxon signed rank test:
for k=1:5; disp(signtest(data_all(k,:),data_all(k+1,:))); end

figure(1);
subplot 339
h=plot(data_all, '.-k', 'markersize',12); 
for k=1:44; h(k).Color=[1 1 1]*.7; end
hold on; plot(mean(data_all,2), '.-r', 'linewidth',2, 'markersize',15);
iSubj=4;
plot(data_all(:,iSubj),'.-k', 'markersize',12);
ylim([0 .4]);
xlabel('model'); ylabel('correlation')
set(gca,'xtick', 1:6, 'xticklabel',{'A', 'B', 'C', 'D', 'E', 'F'}); xlim([.5 6.5])
set(gca,'ygrid', 'on');


%title(iSubj)
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2', '../Paper/Fig_A');

%save tmp/mm1 RRR
