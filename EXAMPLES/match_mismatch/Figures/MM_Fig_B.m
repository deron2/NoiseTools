disp('Fig B: match-mismatch');
clear

figure(1); clf;
set(gcf, 'position', [875   792   600   220])

% histograms of \Delta d
%subplot 131
axes('position', [0.1100    0.1900    0.2134    0.77])

iSubj=4;%1:44
load(['../tmp/mm0_', num2str(iSubj)]); % loads 'xx','ss','sr','h','info'

shifts=unique([-128:20:256, 0:10:100, 20:2:40]);
L_A=0:30;
yy=nt_multishift(ss,L_A);
[AA,BB,RR]=nt_cca_crossvalidate(xx,yy,shifts);
[~,iBestShift]=max(mean(RR(1,:,:),3));
bestShift=shifts(iBestShift);

% histogram of \Delta d for small and large segments
SSIZEs=[1.25    10];
h=[]; % array of handles to histograms
for iSSIZE=1:numel(SSIZEs)
    [a,b]=nt_relshift(xx,yy,bestShift);
    NCCs=5;
    ldaflag=0; % first CC
    [D,E,R,EXTRA]=nt_cca_mm(a,b,sr*SSIZEs(iSSIZE),ldaflag,NCCs);
    DD_mismatch=EXTRA.DD_mismatch;
    DD_match=EXTRA.DD_match;
    h(iSSIZE)=histogram(DD_mismatch-DD_match, -.4:.05:.7);
    drawnow;
    hold on
    disp([D,E,R(1)]);
end

set(gca,'fontsize',14);
line([0 0],[0 90], 'color', 'k');
legend(h,'1.25 s', '10s'); legend boxoff
ylabel('count'); xlabel('\Delta d', 'interpreter', 'tex');
set(gca,'ytick', [0 50], 'xtick', [0 .5]);
drawnow

% plot sensitivity and error rate for all subjects
load ('../tmp/Fig_B_data');

axes('position', [0.4108    0.1900    0.2134    0.77]); % [0.4108    0.1900    0.2134    0.3412]
h=plot(DD, 'k'); hold on
for k=1:44; h(k).Color=[1 1 1]*.8; end
iSubj=4;
semilogy(DD(:,iSubj), '.-k', 'markersize', 10); 
set(gca,'fontsize',14)
semilogy(mean(DD,2),'.-r','linewidth',3, 'markersize', 18);
set(gca,'xtick', [1 3 5], 'xticklabel', {'.125','5','20'}, 'ygrid', 'on', 'ytick', [0 1 2 3 4])
xlabel('duration (s)'); 
ylabel('sensitivity index');
xlim([.5 5.5]); 
ylim([0 4])
drawnow


%subplot 133; 
axes('position', [0.7100    0.1900    0.2134    0.77]); % [0.4108    0.1900    0.2134    0.3412]
h=semilogy(max(0.5,100*EE), '.-', 'markersize', 10); hold on
for k=1:44; h(k).Color=[1 1 1]*.8; end
iSubj=4;
semilogy(max(0.5,100*EE(:,iSubj)), '.-k', 'markersize', 10); 
h=semilogy(100*EE, '.-', 'markersize', 10);
for k=1:44; h(k).Color=[1 1 1]*.8; end
iSubj=4;
semilogy(100*EE(:,iSubj), '.-k', 'markersize', 10); 
set(gca,'fontsize',14)
semilogy(mean(100*EE,2),'.-r','linewidth',3, 'markersize', 18);
set(gca,'ytick',[.5 1 2 5 10 20 50], 'yticklabel',[0 1 2 5 10 20 50])
set(gca,'xtick', [1 3 5], 'xticklabel', {'.125','5','20'}, 'ygrid', 'on')
xlabel('duration (s)'); ylabel('error (%)');
ylim([.5 60]);
xlim([.5 5.5]); 
h=line([0 6],[50,50]); h.LineStyle=':'; h.Color='k';
drawnow



%title(iSubj)
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2', '../Paper/Fig_B');

%save tmp/mm1 RRR
