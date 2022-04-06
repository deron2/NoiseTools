function [bstats,wstats,cstats,sstats]=nt_idxx(fname,iname,blksize,channels_to_keep,nfft,chunksize)
%nt_idxx(fname,iname,blksize,chunksize,nfft) - create an index file to summarize large data file
%
%  fname: name of data file to index
%  iname: name of index file to create [default fname with EXT = .idxx in directory i]
%  bsize: size of blocks over which to calculate stats [default: 100]
%  channels_to_keep: ignore other channels
%  nfft: fft size for psd [default: 1024]
%  chunksize: size of chunks to read from disk [default: 500000]
%
% If blksize is a struct, the following fields are expected:
%   blksize.wav:  blocksize to calculate basic statistics [default: 100]
%   blksize.cov:  blocksize to calculate covariance [default: none]
%   blksize.psd: blocksize to calculate psd [default: none]
% If blksize is numeric, it refers to basic statistics.
%
% Usage:
%   nt_idx(fname,...): calculate index structs, store in index file
%
%   [bstats,wstats,cstats,sstats]=nt_idx(fname,...): return index structs:
%     bstats: basic stats (size, etc.)
%     wstats: waveform (min, max, mean, std)
%     cstats: covariance
%     sstats: psd
%
% NoiseTools
nt_greetings;



assert(nargin>0, '!');
if nargin<2 ; iname=[]; end
if nargin<3 || isempty(blksize)
    blksize.wav=100;
end
if nargin<4; channels_to_keep=[]; end
if nargin<5 || isempty(nfft); nfft=1024; end
if nargin<6 || isempty(chunksize); chunksize=500000; end

if isnumeric(blksize); tmp=blksize; blksize=[]; blksize.wav=tmp; end
if ~isempty(iname) && ~ischar(iname); error('!'); end % common error

% check for FieldTrip
try, ft_version; catch, disp('You must download FieldTrip from http://www.fieldtriptoolbox.org'); return; end

% use separate structs to make it easy to read just one kind of stats from file
bstats=[]; % index structure for basic stats
wstats=[]; % index structure for waveform
cstats=[]; % index structure for covariance
sstats=[]; % index structure for spectrogram
bstats.fname=fname; 

% read header 
h=ft_read_header(fname);
bstats.header=h;
bstats.sr=h.Fs;
bstats.nsamples=h.nSamples;
bstats.label=h.label;
bstats.nchans=h.nChans;

if isempty(channels_to_keep); channels_to_keep=1:bstats.nchans; end
if any(channels_to_keep>bstats.nchans); error('!'); end
bstats.channels_to_keep=channels_to_keep;
bstats.nchans=numel(channels_to_keep);

% allocate basic stats arrays:
nbasic=ceil(bstats.nsamples/blksize.wav); % total number of blocs for basic stats
wstats.min=zeros(nbasic,bstats.nchans);
wstats.max=zeros(nbasic,bstats.nchans); 
wstats.mean=zeros(nbasic,bstats.nchans);
wstats.rms=zeros(nbasic,bstats.nchans);
wstats.card=zeros(nbasic,1,'uint32');

chunksize=floor(chunksize/blksize.wav)*blksize.wav; 

% allocate covariance array
if isfield(blksize,'cov')
    tmp=log2(blksize.cov/blksize.wav);
    assert(tmp==round(tmp), ...
        'blksize.cov should be power of 2 times blksize.wav');
    ncov=ceil(bstats.nsamples/blksize.cov);
    cstats.cov=zeros(ncov,bstats.nchans,bstats.nchans);
    cstats.card=zeros(ncov,1,'uint32');
    chunksize=floor(chunksize/blksize.cov)*blksize.cov;
end

% allocate psd array
if isfield(blksize,'psd') 
    if blksize.psd < nfft; error('!'); end;
    tmp=log2(blksize.psd/blksize.wav);
    assert(tmp==round(tmp), ...
        'blksize.psd should be power of 2 times blksize.wav');
    npsd=ceil(bstats.nsamples/blksize.psd);
    sstats.psd=zeros(npsd,bstats.nchans,nfft/2+1);
    sstats.card=zeros(npsd,1,'uint32');
    sstats.nfft=nfft;
    chunksize=floor(chunksize/blksize.psd)*blksize.psd;
end


foffset=0;
boffset=0;
coffset=0;
soffset=0;

while true
    
    %if file_offset>=i.nsamples; break; end
    
    % read chunk from disk
    begsample=foffset+1;
    endsample=min(foffset+chunksize,bstats.nsamples);
    x=ft_read_data(fname, 'begsample',begsample,'endsample',endsample);
    x=x'; % --> time X channels
    x=x(:,channels_to_keep);
    
    % fold chunk into blocks
    n=floor(size(x,1)/blksize.wav); % number of blocks in this chunk
    xb=x(1:n*blksize.wav,:);
    xb=reshape(xb,[blksize.wav,n,bstats.nchans]);
    wstats.min(boffset+(1:n),:)=min(xb);
    wstats.max(boffset+(1:n),:)=max(xb);
    wstats.mean(boffset+(1:n),:)=mean(xb);
    wstats.rms(boffset+(1:n),:)=sqrt(mean(xb.^2));
    wstats.card(boffset+(1:n),:)=blksize.wav;
    boffset=boffset+n; 

    % extra bit at end of file?
    if size(x,1)>n*blksize.wav
        tmp=x(n*blksize.wav+1:end,:);
        wstats.min(boffset+1,:)=min(tmp);
        wstats.max(boffset+1,:)=max(tmp);
        wstats.mean(boffset+1,:)=mean(tmp);
        wstats.rms(boffset+1,:)=sqrt(mean(tmp.^2));
        wstats.card(boffset+1,:)=size(tmp,1);
    end
    
    
    foffset=foffset+n*blksize.wav;

    if ~isempty(cstats) && isfield(cstats, 'cov')
        n=floor(size(x,1)/blksize.cov); % number of blocks
        xb=x(1:n*blksize.cov,:);        
        xb=reshape(xb,[blksize.cov, n, bstats.nchans]);
        for iBlock=1:n
            tmp=squeeze(xb(:,iBlock,:));
            tmp=nt_demean(tmp);
            cstats.cov(coffset+iBlock,:,:) = tmp'*tmp;
            cstats.cardcov(coffset+iBlock,:)=blksize.cov;
        end
        coffset=coffset+size(xb,2);
        if size(x,1)>n*blksize.cov
            tmp=x(n*blksize.cov+1:end,:);
            tmp=nt_demean(tmp);
            cstats.cov(coffset+1,:,:)=tmp'*tmp;
            cstats.cardcov(coffset+1,:)=size(tmp,1);
        end              
    end
       
    if ~isempty(sstats) && isfield(sstats, 'psd')
        n=floor(size(x,1)/blksize.psd); % number of blocks
        xb=x(1:n*blksize.psd,:);        
        xb=reshape(xb,[blksize.psd, n, bstats.nchans]);
        for iBlock=1:n
            tmp=squeeze(xb(:,iBlock,:));
            tmp=nt_demean(tmp);
            sstats.psd(soffset+iBlock,:,:) = pwelch(tmp, nfft, 'power')';
            sstats.cardpsd(soffset+iBlock,:,:)=blksize.psd;
        end
        soffset=soffset+size(xb,2);
        if size(x,1)>n*blksize.psd
            tmp=x(n*blksize.psd+1:end,:);
            if size(tmp,1)<nfft; break; end
            tmp=nt_demean(tmp);
            sstats.psd(soffset+1,:,:) = pwelch(tmp, nfft, 'power')';
            sstats.cardpsd(soffset+1,:)=size(tmp,1);
        end              
    end
    
    nt_whoss
    disp([num2str(foffset), '/', num2str(h.nSamples), ' (', num2str(foffset/h.nSamples*100), '%)']);
    disp([boffset, coffset, soffset]);
    
    if endsample>=bstats.nsamples; break; end;
end
   
if ~nargout
    if isempty(iname)
        [FILEPATH,NAME,EXT]=fileparts(fname);
        if isempty(FILEPATH); FILEPATH=pwd; end
        if ~exist([FILEPATH,filesep,'idxx'], 'dir')
            mkdir([FILEPATH,filesep,'idxx']);
        end        
        iname=[FILEPATH,filesep,'idxx',filesep,NAME,EXT,'.idxx'];
    end
    wstats.min=nt_double2int(wstats.min); 
    wstats.max=nt_double2int(wstats.max);
    wstats.mean=nt_double2int(wstats.mean);
    wstats.rms=nt_double2int(wstats.rms);
    save(iname, 'bstats', 'wstats','cstats', 'sstats','-v7.3');
    clear bstats wstats cstats sstats;
end


    

