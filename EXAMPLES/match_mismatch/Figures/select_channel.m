function y=select_channel(x,chans)
%y=select_channel(x,chans) - select channels of data stored as cell array
%
%  y: selected data
%
%  x: original data
%  chans: list of channels to select

if ~iscell(x); error('!'); end

y={};
for iTrial=1:numel(x);
    y{iTrial}=x{iTrial}(:,chans,:);
end

