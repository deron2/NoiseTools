disp('Fig C: MM parameter sensitivity L_A=L_X');
% depends on mm6b.m
clear

figure(1); clf;
set(gcf, 'position', [875   792   600   350])

load('../tmp/Fig_G_data');

% subplot 121; h=plot(squeeze(mean(DDD,1)), '-');
% set(gca,'fontsize',14);
% set(gca,'xtick',1:7,'xticklabel',models)
% set(gca,'ygrid','on');
% xlabel('Model');
% ylabel('Sensitivity Index');
% set(h(1),'color',[0.9290 0.6940 0.1250])
% set(h(2),'color',[0.8500 0.3250 0.0980])
% set(h(3),'linewidth',3, 'color','r', 'marker', '.', 'markersize', 18)
% set(h(4),'color',[0.4940 0.1840 0.5560])
% legend(h,'1.25s', '2.5s','5s','10s', 'location','northwest'); legend boxoff
% ylim([0 3]); xlim([.5 7.5])
% set(gca,'ytick',[0 1 2 3])
% 
% 
% subplot 122; 

h=semilogy(100*squeeze(mean(EEE,1)), '-');
set(gca,'fontsize',14);
set(gca,'xtick',1:7,'xticklabel',models)
set(gca,'ygrid','on');
xlabel('Model');
ylabel('error rate (%)');
line([0 8],[50 50],'color','k','linestyle', ':')
set(h(1),'color',[0.9290 0.6940 0.1250])
set(h(2),'color',[0.8500 0.3250 0.0980])
set(h(3),'linewidth',3, 'color','r', 'marker', '.', 'markersize', 18)
set(h(4),'color',[0.4940 0.1840 0.5560])
legend(h,'1.25s', '2.5s','5s','10s', 'location','southwest'); legend boxoff
ylim([.5 60]); xlim([.5 7.5])
set(gca,'ytick',[1 10 ], 'yticklabel', {'1','10'})
set(gca,'xgrid','on');

set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2', '../Paper/Fig_G');
