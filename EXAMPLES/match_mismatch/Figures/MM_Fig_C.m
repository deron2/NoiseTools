disp('Fig C: MM parameter sensitivity L_A=L_X');
% depends on mm6b.m
clear

figure(1); clf;
set(gcf, 'position', [875   792   600   220])

load('../tmp/Fig_C_data');

iSubj=4;

figure(1); clf;


subplot 131; 
h=plot (1:7, modelF.RRR, '.-', 'markersize', 10); 
hold on
for k=1:numel(h); h(k).Color=[1 1 1]*.8; end
plot(1:7 , modelF.RRR(:,iSubj),'k', 'markersize', 10); 
set(gca,'ygrid','on', 'fontsize',14)
ylim([0 .3])
plot([1 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8], mean(modelF_dyadic.RRR,2), 'o:b','linewidth', 1, 'markersize', 4); ylabel('correlation'); 
plot(1:7, mean(modelF.RRR,2), '.-r','linewidth', 3, 'markersize', 18); ylabel('correlation'); 
xlabel('#lags');
set(gca,'ygrid','on', 'fontsize',14)
set(gca,'xtick', 2:2:8, 'xticklabel', [ 2  8  32  128]);
ylim([0 .5])
xlim([.5, 8.5])

subplot 132; 
h=plot(1:7 , modelF.DDD, '.-', 'markersize', 10); 
for k=1:numel(h); h(k).Color=[1 1 1]*.8; end
hold on
plot([1 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8], mean(modelF_dyadic.DDD,2), 'o:b','linewidth', 1, 'markersize', 4); ylabel('sensitivity index'); 
plot(1:7 , mean(modelF.DDD,2),'r.-','linewidth', 3, 'markersize', 18); ylabel('sensitivity index');
plot(1:7 , modelF.DDD(:,iSubj),'k', 'markersize', 10); 
xlabel('#lags');
xlim([.5, 8.5])
ylim([0, 4])
set(gca,'ygrid','on', 'fontsize',14)
set(gca,'xtick', 2:2:8, 'xticklabel', [ 2  8  32  128]);
%text(1, 3,'D=5s','fontsize',12)

subplot 133; 
h=semilogy(1:7 , max(0.5,100*modelF.EEE), '.-', 'markersize', 10); 
for k=1:numel(h); h(k).Color=[1 1 1]*.8; end
hold on
h=semilogy(1:7 , 100*modelF.EEE, '.-', 'markersize', 10); 
for k=1:numel(h); h(k).Color=[1 1 1]*.8; end
semilogy(1:7 , max(0.5,100*modelF.EEE(:,iSubj)),'.-k', 'markersize', 10); 
set(gca,'ygrid','on', 'fontsize',14)
set(gca,'xtick', 2:2:8, 'xticklabel', [ 2  8  32  128]);
set(gca,'ytick', [0.5 1 2 5 10 20 50] , 'yticklabel', [0 1 2 5 10 20 50]);
semilogy([1 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8], 100*mean(modelF_dyadic.EEE,2), 'o:b','linewidth', 1, 'markersize', 4); ylabel('correlation'); 
semilogy(1:7 , mean(100*modelF.EEE,2), '.-r','linewidth', 3, 'markersize', 18); 
ylim([.5 50])
ylabel('error (%)'); 
xlabel('#lags');
%text(1, 40,'D=5s','fontsize',12)
xlim([.5, 8.5])

%title(iSubj)
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2', '../Paper/Fig_C');
set(gca,'ygrid','on');

disp('')
disp('Compare model with lags to model with a dyadic filterbank (same maximum lag for both):')
disp('number of subjects with zero error (lags, dyadic): ')
disp([numel(find(min(modelF.EEE)==0)), numel(find(min(modelF_dyadic.EEE)==0))]);
disp('minimum of average error over subjects (lags, dyadic):');
disp([min(mean(modelF.EEE,2)),min(mean(modelF_dyadic.EEE,2))])
disp('maximum of average dprime over subjects (lags, dyadic):');
disp([max(mean(modelF.DDD,2)),max(mean(modelF_dyadic.DDD,2))])

idxHI=[1:20,41,42];
idxNH= [21:40,43,44];
disp('');
disp('Compare normal hearing and hearing impaired:')
disp('max dprime, NH, HI:');
disp([mean(max(modelF_dyadic.DDD(:,idxHI))), mean(max(modelF_dyadic.DDD(:,idxNH)))])
disp('min error, NH, HI:');
disp([mean(min(modelF_dyadic.EEE(:,idxHI))), mean(min(modelF_dyadic.EEE(:,idxNH)))])
[h,p]=ttest(max(modelF_dyadic.DDD(:,idxHI)), max(modelF_dyadic.DDD(:,idxNH))); 
disp('t-test of difference in d-prime between NH, HI, p=');
disp(p)


