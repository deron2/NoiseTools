disp('Data for Fig_G');
clear

%bestShift=22;  % use same for all subjects

SSIZES=[1.25 2.5 5 10];

models={'A','B','C','D','E','F','G'};
DDD=[];
EEE=[];
RRR=[];
RRRR=[];

    
for iSubj=1:44 % % good: 9 4 13 41 1 25, bad: 2 27 28 36 23 26
    for iSSIZE=1:numel(SSIZES)
        SSIZE=SSIZES(iSSIZE);

        load(['../tmp/mm0_', num2str(iSubj)]); % 0.5 Hz HPF

        % model A
        a=xx;
        b=ss;
        
        % first, get the best shift
        shifts=10:2:42; 
        [AA,BB,RR]=nt_cca_crossvalidate(a,b,shifts);
        [~,iBestShift]=max(mean(RR(1,:,:),3));
        [aa,bb]=nt_relshift(a,b,shifts(iBestShift));
        
        % next, get best channel (based on trial 1)
        cc=[];
        for iChannel=1:size(aa,2)
            cc(:,iChannel)=xcorr(nt_normcol(aa{1}(:,iChannel)),nt_normcol(bb{1}))/size(bb{1},1);
        end
        [~,iBestChannel]=max(max(abs(cc)));
        aa=select_channel(aa,iBestChannel);
         
        % finally, estimate D,E,R
        [D,E,R]=nt_cca_mm(aa,bb,sr*SSIZE);
        DDD(iSubj,1,iSSIZE)=D;
        EEE(iSubj,1,iSSIZE)=E;
        RRR(iSubj,1,iSSIZE)=R(1);        
        disp([iSubj, 1, shifts(iBestShift), iBestChannel])
        disp([SSIZE,R(1),D,E])

        % model B
        a=select_channel(xx,iBestChannel); % best channel from model A
        LA=11;
        b=nt_multishift(ss,0:LA-1);
        
        shifts=10:2:40; 
        [AA,BB,RR]=nt_cca_crossvalidate(a,b,shifts);
        [~,iBestShift]=max(mean(RR(1,:,:),3));
        [aa,bb]=nt_relshift(a,b,shifts(iBestShift));
        a=a(:,iBestChannel);
        [D,E,R]=nt_cca_mm(aa,bb,sr*SSIZE);
        DDD(iSubj,2,iSSIZE)=D;
        EEE(iSubj,2,iSSIZE)=E;
        RRR(iSubj,2,iSSIZE)=R(1);
        disp([iSubj,2, shifts(iBestShift)])
        disp([SSIZE,R(1),D,E])

        % model C
        a=xx;
        LA=1;
        b=nt_multishift(ss,0:LA-1);

        shifts=10:2:40; 
        [AA,BB,RR]=nt_cca_crossvalidate(a,b,shifts);
        [~,iBestShift]=max(mean(RR(1,:,:),3));

        [aa,bb]=nt_relshift(a,b,shifts(iBestShift));
        NCCs=5;
        ldaflag=2;
        [D,E,R]=nt_cca_mm(aa,bb,sr*SSIZE,ldaflag,NCCs);
        DDD(iSubj,3,iSSIZE)=D;
        EEE(iSubj,3,iSSIZE)=E;
        RRR(iSubj,3,iSSIZE)=R(1);
        disp([iSubj,3, shifts(iBestShift)])
        disp([SSIZE,R(1),D,E])


        % model D
        a=xx;
        LA=11;
        b=nt_multishift(ss,0:LA-1);

        shifts=10:2:40;
        [AA,BB,RR]=nt_cca_crossvalidate(a,b,shifts);
        [~,iBestShift]=max(mean(RR(1,:,:),3));

        [aa,bb]=nt_relshift(a,b,shifts(iBestShift));
        NCCs=5;
        ldaflag=2;
        [D,E,R]=nt_cca_mm(aa,bb,sr*SSIZE,ldaflag,NCCs);
        DDD(iSubj,4,iSSIZE)=D;
        EEE(iSubj,4,iSSIZE)=E;
        RRR(iSubj,4,iSSIZE)=R(1);
        disp([iSubj,4, shifts(iBestShift)])
        disp([SSIZE,R(1),D,E])


        % reduce to 32 dims using SCA (should really be only for model G,
        % but putting it here makes little difference and speeds
        % calculation)
        toscs=nt_sca(xx);
        xx=nt_mmat(xx,toscs(:,1:32));


        % model E
        LX=11;
        a=nt_multishift(xx,0:LX-1);
        b=ss;

        shifts=10:2:40; 
        [AA,BB,RR]=nt_cca_crossvalidate(a,b,shifts);
        [~,iBestShift]=max(mean(RR(1,:,:),3));

        [aa,bb]=nt_relshift(a,b,shifts(iBestShift));
        NCCs=5;
        ldaflag=2;
        [D,E,R]=nt_cca_mm(aa,bb,sr*SSIZE,ldaflag,NCCs);
        DDD(iSubj,5,iSSIZE)=D;
        EEE(iSubj,5,iSSIZE)=E;
        RRR(iSubj,5,iSSIZE)=R(1);
        disp([iSubj,5, shifts(iBestShift)])
        disp([SSIZE,R(1),D,E])


        % model F
        LX=11;
        LA=11;
        a=nt_multishift(xx,0:LX-1);
        b=nt_multishift(ss,0:LA-1);

        shifts=10:2:40; 
        [AA,BB,RR]=nt_cca_crossvalidate(a,b,shifts);
        [~,iBestShift]=max(mean(RR(1,:,:),3));

        [aa,bb]=nt_relshift(a,b,shifts(iBestShift));
        NCCs=5;
        ldaflag=2;
        [D,E,R]=nt_cca_mm(aa,bb,sr*SSIZE,ldaflag,NCCs);
        DDD(iSubj,6,iSSIZE)=D;
        EEE(iSubj,6,iSSIZE)=E;
        RRR(iSubj,6,iSSIZE)=R(1);
        disp([iSubj,6, shifts(iBestShift)])
        disp([SSIZE,R(1),D,E])

        % model G
        
        LX=32;
        LA=32;
        a=nt_multishift(xx,0:LX-1);
        b=nt_multishift(ss,0:LA-1);
        [aa,bb]=nt_relshift(a,b,shifts(iBestShift));
        NCCs=5;
        ldaflag=2;
        [D,E,R]=nt_cca_mm(aa,bb,sr*SSIZE,ldaflag,NCCs);
        DDD(iSubj,7,iSSIZE)=D;
        EEE(iSubj,7,iSSIZE)=E;
        RRR(iSubj,7,iSSIZE)=R(1);
        disp([iSubj,7, shifts(iBestShift)])
        disp([SSIZE,R(1),D,E])

        figure(1); clf;
        subplot 132; plot(squeeze(mean(DDD,1)));
        subplot 133; semilogy(squeeze(mean(EEE,1)));
        subplot 131; plot(squeeze(mean(RRR,1)));
        drawnow
    end
end

save('../tmp/Fig_G_data','EEE', 'DDD', 'RRR', 'models');



