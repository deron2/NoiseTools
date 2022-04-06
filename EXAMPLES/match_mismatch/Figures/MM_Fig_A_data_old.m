disp('Precalculate data for Fig_A, models A - F');
clear
%addpath /Users/adc/05/WORK/X/MATLAB

figure(1); clf
set(gcf, 'position', [875   792   600   540])

% Choose the subject for panels 1-6
iSubj=4; %1:44

load(['../tmp/mm0_', num2str(iSubj)]); % loads 'xx','ss','sr','h','info'

%%%%% model D %%%%%%%
tic;
shifts=unique([-128:20:256, 0:5:100]);
L_A=0:10;
[A,B,R]=nt_cca(xx,nt_multishift(ss,L_A),shifts);
[AA,BB,RR]=nt_cca_crossvalidate(xx,nt_multishift(ss,L_A),shifts);
data_D{1}=R;
data_D{2}=mean(RR,3)';
toc;

%%%%% model E %%%%%%%
tic;
L_X=0:10;
y=nt_multishift(xx,L_X);
[A,B,R]=nt_cca(y,ss,shifts);
[AA,BB,RR]=nt_cca_crossvalidate(y,ss,shifts);
data_E{1}=R;
data_E{2}=mean(RR,3)';
toc;

%%%%% model F %%%%%%%
tic;
L_A=0:10;
L_X=0:10;
y=nt_multishift(xx,L_X);
sss=nt_multishift(ss,L_A);
[A,B,R]=nt_cca(y,sss,shifts);
[AA,BB,RR]=nt_cca_crossvalidate(y,sss,shifts);
data_F{1}=R;
data_F{2}=mean(RR,3)';
toc;

%%%%% stats for all the models on all subjects
shifts2=0:2:50;
L_A=0:10;

data_all=[];
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
        ssm=nt_multishift(ss,L_A);
        yy=select_channel(xx,iBestChannel);
        [yy,ssm]=nt_relshift(yy,ssm,shifts2(iShift));
        [bb,z]=nt_proj_crossvalidate(yy,ssm);
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

save ('../tmp/Fig_A_data', 'data_D', 'data_E', 'data_F', 'data_all', 'shifts');

