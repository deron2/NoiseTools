disp('preprocess DTU stim-resp data, including downsampling to 128 Hz, HP=0.5 Hz');
clear

% parameters
DSR=4; % downsampling ratio determines computational cost
HPF=0.5; % Hz - high pass
LPF=30; % Hz - low pass

% data files:
dname='/data/MEG/DTU/ds-eeg-snhl/';
if ~exist(dname, 'dir'); 
    disp('Data not found: download from https://zenodo.org/record/3618205#.X0eDQy3Mywk');
    return;
end

% tmp directory for preprocessed data:
tmpdname='../tmp/';
if ~exist(tmpdname,'dir')
    mkdir (tmpdname);
end

figure(2); clf;

% load, preprocess
for iSubj=1:44
    
    disp(['subject', num2str(iSubj), ' of 44']);

    subject_number=num2str(iSubj,'%03d');
    eegname=['sub-',subject_number,'_task-selectiveattention_eeg.bdf'];
    infoname=['sub-',subject_number,'/eeg/sub-',subject_number,'_task-selectiveattention_events.tsv'];

    single_speaker_events={'224' '248' '254' '135'};

    % info file says which trials are single-speaker
    info=tdfread([dname,infoname]);
    idxSS=[]; 
    for k=1:numel(single_speaker_events)
        idxSS=[idxSS;find(strcmp(single_speaker_events(k),num2cell(info.value,2)))];
    end
    onsets=info.onset(idxSS);
    stimnames=info.stim_file(idxSS,:);

    % purge list of single-speaker trials of  bad entries:
    tmp_idxSS=idxSS;
    tmp_stimnames=stimnames;
    tmp_onsets=onsets;
    for k=1:numel(idxSS)
        if contains(stimnames(k,:),'n/a') % missing stimfile (error?)
            tmp_stimnames(k,:)=[];
            tmp_onsets(k)=[];
            tmp_idxSS(k)=[];
        end
    end
    idxSS=tmp_idxSS;
    stimnames=tmp_stimnames;
    onsets=tmp_onsets;

    % load EEG of entire session
    disp('load EEG...'); tic; 
    h=sopen([dname,'sub-',subject_number,'/eeg/',eegname]);
    sr=h.SampleRate;
    x=sread(h);
    sclose(h);
    x=x(:,1:66); % include also eye channels 65, 66
    toc;

    % apply boxcar filter to smooth and suppress line artifact
    x=nt_smooth(x,sr/50);

    % downsample for speed
    x=nt_dsample(x,DSR); % boxcar downsampling is OK for our purposes
    sr=sr/DSR;

    % detrend entire session
    disp('detrend, filter...'); 
    if 1
        % extra parameter forces detrending in shorter windows
        tic;
        x=nt_detrend(nt_demean(x),2,[],[],[],[],sr*15);  % x,order,w,basis,thresh,niter,wsize
        toc;
    else
        % standard detrend over whole data
        x=nt_detrend(nt_demean(x),2);  % x,order,w,basis,thresh,niter,wsize
    end

    % highpass & lowpass filter
    x=nt_demean(x,1:2*sr);
    [b,a]=butter(2,HPF/(sr/2),'high');
    x=nt_demean(x);
    x=filter(b,a,x);
    LPF=30;
    [b,a]=butter(2,LPF/(sr/2),'low');
    x=filter(b,a,x);
    toc

    if 1     
        disp(' remove eyeblink...');
        tic;
        NREMOVE=2; % should be per-subject to avoid removing brain components if no eyeblink  
        [x,y]=nt_eyeblink(x(:,:),x(:,[65,66,1,33,34]),NREMOVE,sr);
        figure(10); clf; plot(y); drawnow
        toc;
        %pause
    end 
    
    % keep only EEG channels
    x=x(:,1:64); 
    toc;

    % chop EEG into trials, store together with stimulus envelope
    ss={};
    xx={};
    tic;
    for iTrial=1:numel(idxSS)
        
        disp(['trial: ', num2str(iTrial)]);
        
        % load stimulus
        stimname=stimnames(iTrial,:);
        load([dname,'derivatives/stimuli/',stimname(1:end-4),'.mat']); % loads 'dat'

        % downsample, apply the same filters as to EEG
        ss{iTrial}=nt_dsample(dat.feat,DSR);
        [b,a]=butter(2,HPF/(sr/2),'high');
        ss{iTrial}=filter(b,a,ss{iTrial});
        [b,a]=butter(2,LPF/(sr/2),'low');
        ss{iTrial}=filter(b,a,ss{iTrial});

        % excise the corresponding portion of EEG, detrend, demean
        tmp=x(round(sr*onsets(iTrial))+(1:size(ss{iTrial},1)),:);      
        ORDER=1;
        tmp=nt_detrend(nt_demean(tmp),ORDER);
        tmp=nt_demean(tmp);
        xx{iTrial}=tmp;

        % fill in missing trial(s)
        if isempty(xx{iTrial}); xx{iTrial}=zeros(1,64); end 
    end
    toc;

    nt_whoss;
    figure(2); 
    subplot(5,9,iSubj)
    x=cell2mat(xx');
    plot(x); drawnow; title(iSubj);

    save([tmpdname, 'mm0_', num2str(iSubj)], 'xx','ss','sr','h','info');
end



