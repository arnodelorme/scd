% pop_currentdensity() - compute scalp current density and replace EEG data
%
% Usage :
%    >> EEGOUT = pop_currentdensity( EEGIN )
%    >> EEGOUT = pop_currentdensity( EEGIN, 'key', val )
%
% Inputs:
%   EEGIN   - A EEG structure containig the EEG.data an the EEG.chanlocs
%   'key', val  - Parameters for ft_scalpcurrentdensity
%
% Inputs:
%   EEGOUT  - A EEG structure with the ICA activities replaced by the
%             laplacian
%
% See also: ft_scalpcurrentdensity()
%
% Author: Arnaud Delorme, 2021

% Copyright (C) 2021 Arnaud Delorme
%
% This file is part of EEGLAB, see http://www.eeglab.org
% for the documentation and details.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
% THE POSSIBILITY OF SUCH DAMAGE.

function [EEG,com] = pop_currentdensity(EEG, varargin)

com = '';
if nargin < 1
	help pop_laplac;
	return;
end

plugin_askinstall('fieldtrip', 'ft_scalpcurrentdensity');

% pop up window
% -------------
if nargin < 2
    res2 = questdlg2('This will replace EEG data with scalp current densities', 'pop_laplac - laplacian', 'NO', 'YES', 'NO');
    if strcmpi(res2, 'NO')
        return;
    end
    
    methods = { 'finite' 'spline' 'hjorth' };
    textui = { { 'style' 'text' 'string' 'Select method' } ...
               { 'style' 'popupmenu' 'string' methods } ...
               { 'style' 'text' 'string' 'Method parameter' } ...
               { 'style' 'edit' 'string' '' } };
    res = inputgui( 'uilist', textui, 'geometry', { [1 1] [1 1] }, 'title', 'pop_currentdensity', 'helpcom', 'pophelp(''pop_currentdensity'')');
    if isempty(res)
        return
    end
    
    method = methods{res{1}};
    tmpopts = eval( [ '{' res{2} '}' ]);
    options = { 'method' method tmpopts{:} };
else
    options = varargin;
end

% process multiple datasets
% -------------------------
if length(EEG) > 1
    if nargin < 2
        [ EEG,com ] = eeg_eval( 'pop_currentdensity', EEG, 'warning', 'on', 'params', options );
    else
        [ EEG,com ] = eeg_eval( 'pop_currentdensity', EEG, 'params', options );
    end
    return;
end

if any(cellfun(@isempty, { EEG.chanlocs.X }))
    fprintf(2, 'Warning: some channels do not have associated coordinates. This\ncould create problems for computing scalp current density.\n');
end

data = eeglab2fieldtrip(EEG, 'raw');

cfg = struct(options{:});
cfg.elec = data.elec;

[tmpdata] = ft_scalpcurrentdensity(cfg, data);

if length(tmpdata.trial) == 1
    EEG.data = tmpdata.trial{1};
else
    EEG.data = [ tmpdata.trial{:} ];
    EEG.data = reshape(EEG.data, EEG.nbchan, EEG.pnts, EEG.trials);
end
    
% disp('Computing laplacian...');
% EEG.data = eeg_laplac(EEG, 1);
com = sprintf('EEG = pop_currentdensity(EEG, %s);', vararg2str(options));
