disp('Fig_D: performance vs number of channels or spatial PCs');
clear

%N=[1 2 4 8 11 16 23 32 45 64];

figure(1); clf;
set(gcf, 'position', [875   792   600   220])

load('tmp/Fig_D_data');

subplot 131
plot([1 2 3 4 4.5 5 5.5 6 6.5 7], mean(RRR(:,2,:),3), '.-r', 'linewidth', 2); hold on
plot([1 2 3 4 4.5 5 5.5 6 6.5 7], mean(RRR(:,3,:),3), '.-b');
plot([1 2 3 4 4.5 5 5.5 6 6.5 7], mean(RRR(:,1,:),3), ':k');
legend('PCA', 'SCA', 'best channels', 'location','southeast'); legend boxoff
set(gca,'xtick', 1:7, 'xticklabel', [1 2 4 8 16 32 64], 'xgrid','on', 'ygrid', 'on');
set(gca,'ytick',[0 .1 .2]);
ylabel('correlation');
ylim([0 .17]);
xlabel('N');

subplot 132
plot([1 2 3 4 4.5 5 5.5 6 6.5 7], mean(DDD(:,2,:),3), '.-r', 'linewidth', 2); hold on
plot([1 2 3 4 4.5 5 5.5 6 6.5 7], mean(DDD(:,3,:),3), '.-b');
plot([1 2 3 4 4.5 5 5.5 6 6.5 7], mean(DDD(:,1,:),3), ':k'); hold on
%legend('PCA', 'SCA', 'best channels', 'location','southeast'); legend boxoff
set(gca,'xtick', 1:7, 'xticklabel', [1 2 4 8 16 32 64], 'xgrid','on', 'ygrid', 'on');
ylabel('sensitivity index');
ylim([0 1.3]);
xlabel('N');

subplot 133
semilogy([1 2 3 4 4.5 5 5.5 6 6.5 7], max(0.5, 100*mean(EEE(:,2,:),3)), '.-r', 'linewidth', 2); hold on
semilogy([1 2 3 4 4.5 5 5.5 6 6.5 7], max(0.5, 100*mean(EEE(:,3,:),3)), '.-b');
semilogy([1 2 3 4 4.5 5 5.5 6 6.5 7], max(0.5, 100*mean(EEE(:,1,:),3)), ':k'); hold on
%legend(''PCA', 'SCA', best channels', 'location','northeast'); legend boxoff
set(gca,'xtick', 1:7, 'xticklabel', [1 2 4 8 16 32 64], 'xgrid','on', 'ygrid', 'on');
ylabel('error rate');
ylim([10 50]);
set(gca,'ytick', [.5 1 2 5 10 20 50], 'yticklabel', [0 1 2 5 10 20 50])
xlabel('N');

labels={'best channels', 'pca', 'sca'};
d=squeeze(mean(DDD));
e=squeeze(mean(EEE));
r=squeeze(mean(RRR));
disp('D:');
for iLabel=1:numel(labels)
    for iLabel2=1:iLabel-1
        p=signtest(d(iLabel,:),d(iLabel2,:));
        if p<0.05
            disp([labels{iLabel}, ' vs ', labels{iLabel2}, ': ',num2str(p)]);
        end
    end
end
disp('E:')
for iLabel=1:numel(labels)
    for iLabel2=1:iLabel-1
        p=signtest(e(iLabel,:),e(iLabel2,:));
        if p<0.05
            disp([labels{iLabel}, ' vs ', labels{iLabel2}, ': ',num2str(p)]);
        end
    end
end
disp('R:')
for iLabel=1:numel(labels)
    for iLabel2=1:iLabel-1
        p=signtest(r(iLabel,:),r(iLabel2,:));
        if p<0.05
            disp([labels{iLabel}, ' vs ', labels{iLabel2}, ': ',num2str(p)]);
        end
    end
end

%title(iSubj)
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2', 'Paper/Fig_D');
set(gca,'ygrid','on');

