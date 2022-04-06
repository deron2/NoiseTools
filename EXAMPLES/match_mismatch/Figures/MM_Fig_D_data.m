disp('MM, best channels vs PCA vs SCA');
clear

%bestShift=22;
N=[1 2 4 8 11 16 23 32 45 64];

L=1; % L_X=L_A


% best subjects: 9 4 13 41 1 25
% worst subjects: 2 27 28 36 23 26
% subject 24 has only 13/16 trials

if 1    
    
    for iSubj=1:44
        disp(iSubj) 
        load(['./tmp/mm0_', num2str(iSubj)]); % 0.5 Hz HPF
        % loads xx ss sr info h
            
        % determine best shift
        if 1
            shifts=-100:2:100;
            [A,B,R]=nt_cca(nt_multishift(xx,0:L-1),nt_multishift(ss,0:L-1),shifts);
            figure(12); clf; plot(shifts,R');
            [~,iBestShift]=max(R(1,:));
            bestShift=shifts(iBestShift);
            disp(bestShift);
        else
            bestShift=22;
        end

        % align EEG & audio
        [a,b]=nt_relshift(xx,ss,bestShift);
        % rank channels in terms of correlation with audio
        [A,B,R]=nt_cca(a,b);
        z=nt_mmat(xx,A);
        C=nt_xcov(nt_cell2mat(z),nt_cell2mat(xx));
        [~,bestChannelOrder]=sort(abs(C), 'descend');

        % best channels
        for iN=1:numel(N)
            aa=select_channel(a,bestChannelOrder(1:N(iN)));
            [D,E,R]=nt_cca_mm(nt_multishift(aa,0:L-1),nt_multishift(b,0:L-1),sr*5,2,3); 
            DD(iN,1)=D;
            EE(iN,1)=E;
            RR(iN,1)=R(1);
        end

        % PCA
        topcs=nt_pca0(a);
        for iN=1:numel(N)
            [D,E,R]=nt_cca_mm(nt_multishift(nt_mmat(a,topcs(:,1:N(iN))),0:L-1),nt_multishift(b,0:L-1),sr*5,2,3); 
            DD(iN,2)=D;
            EE(iN,2)=E;
            RR(iN,2)=R(1);
        end

        % SCA
        toscs=nt_sca(a);
        for iN=1:numel(N)
            [D,E,R]=nt_cca_mm(nt_multishift(nt_mmat(a,toscs(:,1:N(iN))),0:L-1),nt_multishift(b,0:L-1),sr*5,2,3); 
            DD(iN,3)=D;
            EE(iN,3)=E;
            RR(iN,3)=R(1);
        end

        figure(11); clf
        plot(DD);
        legend('best','pca','sca', 'location','southeast');
        set(gca,'xticklabel',N, 'xgrid','on', 'ygrid', 'on');
        title(iSubj);
        figure(12); clf
        plot(EE);
        legend('best','pca','sca', 'location','southeast');
        set(gca,'xticklabel',N, 'xgrid','on', 'ygrid', 'on');
        title(iSubj);
        figure(13); clf
        plot(RR);
        legend('best','pca','sca', 'location','southeast');
        set(gca,'xticklabel',N, 'xgrid','on', 'ygrid', 'on');
        title(iSubj);

        drawnow

        DDD(:,:,iSubj)=DD;
        EEE(:,:,iSubj)=EE;
        RRR(:,:,iSubj)=RR;
    end
    
    save('tmp/Fig_D_data', 'DDD', 'EEE', 'RRR', 'N', 'sr');
else
    load('tmp/Fig_D_data');
end

