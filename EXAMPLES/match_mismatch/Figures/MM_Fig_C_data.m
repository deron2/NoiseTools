disp('Data for Fig_C');
%clear

bestShift=22;  % use same for all subjects
SSIZE=5; % s - segment size
 
for iSubj=1:44 % % good: 9 4 13 41 1 25, bad: 2 27 28 36 23 26
    disp(iSubj) 
    load(['./tmp/mm0_', num2str(iSubj)]); % 0.5 Hz HPF

    toscs=nt_sca(xx);
    xx=nt_mmat(xx,toscs(:,1:32));
    
    
    % model F
    a=xx;
    LAs=[1 2 4 8 16 32 64];
    for iLA=1:numel(LAs)
        LA=LAs(iLA);
        a=nt_multishift(xx,0:LA-1);
        b=nt_multishift(ss,0:LA-1);
        [aa,bb]=nt_relshift(a,b,bestShift);
%         shifts=-50:5:50;
%         [A,B,R]=nt_cca(aa,bb,shifts);
%         figure(2); clf; plot(shifts,R'); set(gca,'xgrid','on'); drawnow
         NCCs=5;
         ldaflag=2;
        [D,E,R]=nt_cca_mm(aa,bb,sr*SSIZE,ldaflag,NCCs);
        modelF.DDD(iLA,iSubj)=D;
        modelF.EEE(iLA,iSubj)=E;
        modelF.RRR(iLA,iSubj)=R(1);;
        disp([iSubj, LA])
        disp([D,E,R(1)])
         %pause;
    end

     % model F with dyadic filterbank
    a=xx;
    SMOOTHs=[1 2 3 4 6 8 11 16 23 32 45 64 91 128];
    for iSMOOTH=1:numel(SMOOTHs)
        a=nt_multismooth(xx,SMOOTHs(1:iSMOOTH));
        b=nt_multismooth(ss,SMOOTHs(1:iSMOOTH));
        [aa,bb]=nt_relshift(a,b,bestShift);
%         shifts=-50:5:50;
%         [A,B,R]=nt_cca(aa,bb,shifts);
%         figure(2); clf; plot(shifts,R'); set(gca,'xgrid','on'); drawnow
         NCCs=5;
         ldaflag=2;
        [D,E,R]=nt_cca_mm(aa,bb,sr*SSIZE,ldaflag,NCCs);
        modelF_dyadic.DDD(iSMOOTH,iSubj)=D;
        modelF_dyadic.EEE(iSMOOTH,iSubj)=E;
        modelF_dyadic.RRR(iSMOOTH,iSubj)=R(1);;
        disp([iSubj, iSMOOTH, SMOOTHs(iSMOOTH)])
        disp([D,E, R(1)])
         %pause;
    end

%     figure(3); clf;
%     subplot 331; h=semilogx(LAs, modelF.DDD); 
%     for k=1:numel(h); h(k).Color=[1 1 1]*.7; end        
%     hold on; semilogx(LAs, mean(modelF.DDD,2), 'r.-', 'linewidth', 2);
%     ylabel('correlation'); xlabel('max lag'); set(gca,'ygrid','on');
% 
%     subplot 332; h=semilogx(SMOOTHs, modelF_dyadic.DDD); 
%     for k=1:numel(h); h(k).Color=[1 1 1]*.7; end        
%     hold on; semilogx(SMOOTHs, mean(modelF_dyadic.DDD,2), 'r.-', 'linewidth', 2);
% 
%     subplot 333; 
%     semilogx(LAs, mean(modelF.DDD,2), '.-'); hold on
%     semilogx(SMOOTHs, mean(modelF_dyadic.DDD,2), '.-'); legend('lags','dyadic')
% 
%     subplot 334; semilogy(LAs, max(.001,modelF.EEE)); hold on; semilogy(LAs, mean(modelF.EEE,2), 'r', 'linewidth', 2);
%     subplot 337; plot(LAs, modelF.RRR); hold on; plot(LAs, mean(modelF.RRR,2), 'r', 'linewidth', 2);
% 
%     subplot 335; semilogy(SMOOTHs, max(.001,modelF_dyadic.EEE)); hold on; semilogy(SMOOTHs, mean(modelF_dyadic.EEE,2), 'r', 'linewidth', 2);
%     subplot 338; plot(SMOOTHs, modelF_dyadic.RRR); hold on; plot(SMOOTHs, mean(modelF_dyadic.RRR,2), 'r', 'linewidth', 2);
% 
%     disp('number of subjects with zero error (lags, dyadic): ')
%     disp([numel(find(min(modelF.EEE)==0)), numel(find(min(modelF_dyadic.EEE)==0))]);
%     disp('minimum of average error over subjects (lags, dyadic):');
%     disp([min(mean(modelF.EEE,2)),min(mean(modelF_dyadic.EEE,2))])
%     disp('maximum of average dprime over subjects (lags, dyadic):');
%     disp([max(mean(modelF.DDD,2)),max(mean(modelF_dyadic.DDD,2))])

end

save('../tmp/Fig_C_data','modelF','modelF_dyadic','SMOOTHs','LAs');


figure(3); clf;
subplot 331; h=semilogx(LAs, modelF.DDD); 
for k=1:numel(h); h(k).Color=[1 1 1]*.7; end        
hold on; semilogx(LAs, mean(modelF.DDD,2), 'r.-', 'linewidth', 2);
ylabel('correlation'); xlabel('max lag'); set(gca,'ygrid','on');

subplot 332; h=semilogx(SMOOTHs, modelF_dyadic.DDD); 
for k=1:numel(h); h(k).Color=[1 1 1]*.7; end        
hold on; semilogx(SMOOTHs, mean(modelF_dyadic.DDD,2), 'r.-', 'linewidth', 2);

subplot 333; 
semilogx(LAs, mean(modelF.DDD,2), '.-'); hold on
semilogx(SMOOTHs, mean(modelF_dyadic.DDD,2), '.-'); legend('lags','dyadic')

subplot 334; semilogy(LAs, max(.001,modelF.EEE)); hold on; semilogy(LAs, mean(modelF.EEE,2), 'r', 'linewidth', 2);
subplot 337; plot(LAs, modelF.RRR); hold on; plot(LAs, mean(modelF.RRR,2), 'r', 'linewidth', 2);

subplot 335; semilogy(SMOOTHs, max(.001,modelF_dyadic.EEE)); hold on; semilogy(SMOOTHs, mean(modelF_dyadic.EEE,2), 'r', 'linewidth', 2);
subplot 338; plot(SMOOTHs, modelF_dyadic.RRR); hold on; plot(SMOOTHs, mean(modelF_dyadic.RRR,2), 'r', 'linewidth', 2);

disp('number of subjects with zero error (lags, dyadic): ')
disp([numel(find(min(modelF.EEE)==0)), numel(find(min(modelF_dyadic.EEE)==0))]);
disp('minimum of average error over subjects (lags, dyadic):');
disp([min(mean(modelF.EEE,2)),min(mean(modelF_dyadic.EEE,2))])
disp('maximum of average dprime over subjects (lags, dyadic):');
disp([max(mean(modelF.DDD,2)),max(mean(modelF_dyadic.DDD,2))])

idxHI=[1:20,41,42];
idxNH= [21:40,43,44];
disp('max dprime, HI, NH:');
disp([mean(max(modelF_dyadic.DDD(:,idxHI))), mean(max(modelF_dyadic.DDD(:,idxNH)))])
disp('min error, HI, NH:');
disp([mean(min(modelF_dyadic.EEE(:,idxHI))), mean(min(modelF_dyadic.EEE(:,idxNH)))])
[h,p]=ttest(max(modelF_dyadic.DDD(:,idxHI)), max(modelF_dyadic.DDD(:,idxNH))); 
disp('t-test:');
disp(p)

