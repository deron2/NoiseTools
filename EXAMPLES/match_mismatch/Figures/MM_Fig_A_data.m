disp('Precalculate data for Fig_A, models A - F');
clear
%addpath /Users/adc/05/WORK/X/MATLAB

figure(1); clf
set(gcf, 'position', [875   792   600   540])

% Choose the subject for panels 1-6
iSubj=4; %1:44

% load preprocessed data
load(['../tmp/mm0_', num2str(iSubj)]); % loads 'xx','ss','sr','h','info'

% xx,ss: cell array of trials, x,s: concatenated trials
x=cell2mat(xx');
s=cell2mat(ss');

%%%%% model A %%%%%%%
% cross-correlation between stimulus and each EEG channel - uses xcorr
for iChannel=1:size(xx{1},2)
    cc(:,iChannel)=xcorr(nt_normcol(x(:,iChannel)),nt_normcol(s))/size(s,1);
end
[~,iBestChannel]=max(max(abs(cc)));
data_A.noxval=cc;
data_A.lags=(-size(cc,1)/2+(1:size(cc,1)))/sr;
data_A.iBestChannel=iBestChannel;

%%%%%%%%% model B %%%%%%%%%%%%%%
% uses corr to best channel on time-shifted stimulus, with a range of shifts
L_A=0:10; % lags to apply to stimulus
subplot 332
data_B.noxval=[]; data_B.xval=[];
shifts=unique([-128:20:256, 0:5:100]); % overall time shift between stimulus and response
for iShift=1:numel(shifts)
    
    % no crossvalidation: simply calculate projection matrix and project
    sm=nt_multishift(s,L_A); % augment stimulus with lags   
    [y,sm]=nt_relshift(x(:,iBestChannel),sm,shifts(iShift));
    b=sm\y;
    z=sm*b;
    data_B.noxval(iShift)=corr(z,y);

    % crossvalidated projection (solution calculated on n-1 trials, applied
    % to left-out trial
    ssm=nt_multishift(ss,L_A);
    yy=select_channel(xx,iBestChannel);
    [yy,ssm]=nt_relshift(yy,ssm,shifts(iShift));
    [bb,z]=nt_proj_crossvalidate(yy,ssm);
    
    % concatenate left-out trials, calculate correlation
    data_B.xval(iShift)=corr(nt_unfold(z),nt_unfold(nt_cell2mat(yy)));
end
data_B.shifts=shifts;

%%%%%%%%% model C %%%%%%%%%%%%%%
% uses nt_cca, nt_cca_crossvalidate
shifts=unique([-128:5:256, -50:2:50]);
y=xx;%nt_mmat(xx,toscs(:,1:10));
[A,B,R]=nt_cca(y,ss,shifts);
[AA,BB,RR]=nt_cca_crossvalidate(y,ss,shifts);
data_C.noxval=R';
data_C.xval=mean(RR,3)';
data_C.shifts=shifts;
bestShift=62; % best shift, ~0.2 s
z=nt_mmat(x,A(:,:,bestShift));
c=nt_xcov(nt_normcol(z),nt_normcol(x))/size(z,1); % cross-correlation between projection of stim on EEG and individual channels
if abs(max(c))<abs(min(c)); c=-c; end % correct sign
data_C.c=c;

%%%%% model D %%%%%%%
tic;
shifts=unique([-128:20:256, 0:5:100]);
L_A=0:10;
[A,B,R]=nt_cca(xx,nt_multishift(ss,L_A),shifts);
[AA,BB,RR]=nt_cca_crossvalidate(xx,nt_multishift(ss,L_A),shifts);
data_D.noxval=R';
data_D.xval=mean(RR,3)';
data_D.shifts=shifts;
toc;

%%%%% model E %%%%%%%
tic;
L_X=0:10;
y=nt_multishift(xx,L_X);
[A,B,R]=nt_cca(y,ss,shifts);
[AA,BB,RR]=nt_cca_crossvalidate(y,ss,shifts);
data_E.noxval=R';
data_E.xval=mean(RR,3)';
data_E.shifts=shifts;
toc;

%%%%% model F %%%%%%%
tic;
L_A=0:10;
L_X=0:10;
y=nt_multishift(xx,L_X);
sss=nt_multishift(ss,L_A);
[A,B,R]=nt_cca(y,sss,shifts);
[AA,BB,RR]=nt_cca_crossvalidate(y,sss,shifts);
data_F.noxval=R';
data_F.xval=mean(RR,3)';
data_F.shifts=shifts;
toc;

%%%%% stats for all the models on all subjects
data_all=[];
shifts2=0:2:50;
L_A=0:10;

%load RRR



for iSubj=1:44
    disp(iSubj)
    load(['../tmp/mm0_', num2str(iSubj)]); % 0.5 Hz HPF
    x=cell2mat(xx');
    s=cell2mat(ss');

    % model A
    cc=[];
    for iChan=1:size(xx{1},2)
        cc(:,iChan)=xcorr(nt_normcol(x(:,iChan)),nt_normcol(s))/size(s,1);
    end
    % best channel in terms of correlation
    [~,iBestChannel]=max(max(abs(cc)));
    tmp=cc(:,iBestChannel);
    figure(4); clf; plot(tmp)
    title('A'); drawnow

    data_all(1,iSubj)=max(abs(tmp));

    % model B
    L_A=0:10;
    cc=[];
    for iShift=1:numel(shifts2)
        ssx=nt_multishift(ss,L_A);
        yy=select_channel(xx,iBestChannel);
        [yy,ssx]=nt_relshift(yy,ssx,shifts2(iShift));
        [bb,z]=nt_proj_crossvalidate(yy,ssx);
        cc(iShift)=corr(nt_unfold(z),nt_unfold(nt_cell2mat(yy)));
    end
    figure(4); clf; plot(cc); drawnow
    title('B'); drawnow
    data_all(2,iSubj)=max(cc);

    % model C
    [AA,BB,RR]=nt_cca_crossvalidate(xx,ss,shifts2);
    tmp=mean(RR,3)';
    figure(5); clf; plot(tmp)
    title('C'); drawnow
    data_all(3,iSubj)=max(tmp);

    % model D
    L_A=0:10;
    [AA,BB,RR]=nt_cca_crossvalidate(xx,nt_multishift(ss,L_A),shifts2);
    tmp=mean(RR,3)';
    figure(6); clf; plot(tmp); 
    title('D'); drawnow
    data_all(4,iSubj)=max(max(tmp));

    % model E
    L_X=0:10;
    y=nt_multishift(xx,L_X);
    [AA,BB,RR]=nt_cca_crossvalidate(y,ss,shifts2);
    tmp=mean(RR,3)';
    figure(6); clf; plot(tmp); 
    title('E'); drawnow
    data_all(5,iSubj)=max(tmp);

    % model F
    L_A=0:10;
    L_X=0:10;
    y=nt_multishift(xx,L_X);
    sss=nt_multishift(ss,L_A);

    [AA,BB,RR]=nt_cca_crossvalidate(y,sss,shifts2);
    tmp=mean(RR,3)';
    figure(7); clf; plot(tmp); drawnow
    title('F');; drawnow
    data_all(6,iSubj)=max(max(tmp));

    figure(8); clf; 
    plot(data_all); drawnow;
end

save ('../tmp/Fig_A_data', 'data_A', 'data_B', 'data_C', 'data_D', 'data_E', 'data_F', 'data_all', 'shifts2', 'sr');

