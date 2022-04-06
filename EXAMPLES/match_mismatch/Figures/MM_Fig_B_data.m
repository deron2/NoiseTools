disp('Precalculate data for Fig B: match-mismatch');
clear

% iSubj=4;%1:44
% load(['../tmp/mm0_', num2str(iSubj)]); % loads 'xx','ss','sr','h','info'

DD=[]; EE=[]; RR=[];
for iSubj=1:44
    disp(iSubj)

    load(['../tmp/mm0_', num2str(iSubj)]); % 0.5 Hz HPF

    % model F
    L_A=0:10;
    L_X=0:10;
    yy=nt_multishift(ss,L_A);
    xx=nt_multishift(xx,L_X);

    shifts=0:5:100;
    [AA,BB,RR]=nt_cca_crossvalidate(xx,yy,shifts);
    [~,iBestShift]=max(mean(RR(1,:,:),3));

    SSIZEs=[1.25  2  5  10 20];
    for iSSIZE=1:numel(SSIZEs)
        [a,b]=nt_relshift(xx,yy,shifts(iBestShift));
        NCCs=5;
        [D,E,R]=nt_cca_mm(a,b,sr*SSIZEs(iSSIZE),[],NCCs);
        DD(iSSIZE,iSubj)=D;
        EE(iSSIZE,iSubj)=E;
        RR(iSSIZE,iSubj)=R(1);

        disp([iSubj,iSSIZE,D,E,R(1)]);

        figure(10); clf;
        subplot 233; h=plot(DD,'.-k'); 
%            for k=1:44; h(k).Color=[1 1 1]*.7; end
        hold on; plot(mean(DD,2),'.-k','linewidth',2);
        xlim([.5 5.5]); 
        set(gca,'ygrid','on','xticklabel',[])
        ylabel('d-prime')
        subplot 236; h=plot(100*EE, '.-', 'markersize', 10);
        %for k=1:44; h(k).Color=[1 1 1]*.7; end
        hold on; plot(mean(100*EE,2),'.-k','linewidth',2);
        set(gca,'ytick',[10 30 50], 'ygrid','on', 'xtick', [1 3 5], 'xticklabel', {'.125','5','20'})
        xlabel('segment duration (s)'); ylabel('error (%)')
        ylim([.5 60]);
        xlim([.5 5.5]); 
        drawnow
    end
end    
save('../tmp/Fig_B_data', 'DD', 'EE', 'RR')

