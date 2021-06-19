% eegplugin_scd() - scalp current density EEGLAB plugin
%
% Usage:
%   >> eegplugin_dipfit(fig, trystrs, catchstrs);
%
% Inputs:
%   fig        - [integer] eeglab figure.
%   trystrs    - [struct] "try" strings for menu callbacks.
%   catchstrs  - [struct] "catch" strings for menu callbacks.
%
% Author: Arnaud Delorme, 2021
%
% See also: eeglab()

% Copyright (C) 2021 Arnaud Delorme
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1.07  USA

function vers = eegplugin_scd(fig, trystrs, catchstrs)
    
    vers = 'scd1.0';
    if nargin < 3
        error('eegplugin_scd requires 3 arguments');
    end
    
    % find tools menu
    % ---------------
    menu = findobj(fig, 'tag', 'tools'); 
    % tag can be 
    % 'import data'  -> File > import data menu
    % 'import epoch' -> File > import epoch menu
    % 'import event' -> File > import event menu
    % 'export'       -> File > export
    % 'tools'        -> tools menu
    % 'plot'         -> plot menu

    % menu callback commands
    % ----------------------
    com = [ trystrs.check_chanlocs '[EEG,LASTCOM] = pop_currentdensity(EEG);' catchstrs.new_and_hist ]; 
    
    % create menus
    % ------------
    uimenu( menu, 'Label', 'Scalp current density', 'separator', 'on', 'userdata', 'startup:off;study:on', 'callback', com);
