function [UserPref, f] = monkeywrench_config(varargin)
% To be called when ~ispref('MonkeyLogic', 'UserPreferences');
%
% Last modified 8/24/12 (to include LFP Spectrogram Preferences)  -WA 

if ispref('MonkeyLogic', 'UserPreferences'),
    UserPref = getpref('MonkeyLogic', 'UserPreferences');
    if ~isfield(UserPref, 'LFPSpectrogram'),
        rmpref('MonkeyLogic', 'UserPreferences');
    end
end

if ~ispref('MonkeyLogic', 'UserPreferences'),
    UserPref.DefaultStartCode = 23;
    UserPref.DefaultStartOffset = 0;
    UserPref.DefaultDuration = 1000;
    UserPref.DefaultSmoothWindow = 50;
    UserPref.StartTrialCode = 9;
    UserPref.EndTrialCode = 18;
    UserPref.StartCodeOccurrence = 1;
    UserPref.IncludeLFP = 1;
    UserPref.UseNexCodes = 1;
    UserPref.LoadSpikes = 1;
    UserPref.LoadLFP = 0;
    UserPref.DefaultNoLocationCode = -99999;
    
    LFPConfig.StartCode = UserPref.DefaultStartCode;
    LFPConfig.StartOffset = UserPref.DefaultStartOffset;
    LFPConfig.Duration = UserPref.DefaultDuration;
    LFPConfig.SmoothWindow = UserPref.DefaultSmoothWindow;
    LFPConfig.SortOnTaskObject = 1;
    LFPConfig.SortOnAttribute = 1;
    LFPConfig.ConditionsGrouping = '';
    LFPConfig.SelectedBlocks = NaN;
    LFPConfig.TrialError = 1;
    LFPConfig.HideRaw = 0;
    LFPConfig.Trial = NaN;
    
    LFPConfig.GlobalMinFreq = 0;
    LFPConfig.GlobalMaxFreq = 70;
    LFPConfig.FreqStep = 3;
    LFPConfig.DeltaMin = 0;
    LFPConfig.ThetaMin = 4;
    LFPConfig.AlphaMin = 8;
    LFPConfig.BetaMin = 14;
    LFPConfig.GammaMin = 30;
    LFPConfig.DeltaMax = 4;
    LFPConfig.ThetaMax = 8;
    LFPConfig.AlphaMax = 14;
    LFPConfig.BetaMax = 30;
    LFPConfig.GammaMax = 70;
    LFPConfig.DeltaUse = 1;
    LFPConfig.ThetaUse = 1;
    LFPConfig.AlphaUse = 1;
    LFPConfig.BetaUse = 1;
    LFPConfig.GammaUse = 1;
    
    UserPref.LFPSpectrogram = LFPConfig;
    
    setpref('MonkeyLogic', 'UserPreferences', UserPref);
else
    UserPref = getpref('MonkeyLogic', 'UserPreferences');
    LFPConfig = UserPref.LFPSpectrogram;
end

f = findobj('tag', 'MonkeyWrenchPreferences');
if ~isempty(f),
    figure(f);
end

if isempty(f),
    f = figure;
    set(gcf, 'numbertitle', 'off', 'name', 'MonkeyWrench User Preferences', 'menubar', 'none', 'position', [200 100 730 450], 'tag', 'MonkeyWrenchPreferences');
    bg = get(gcf, 'color');

    %Default Display Options
    h = uicontrol('style', 'frame', 'position', [20 280 310 120]);
    fbg = get(h, 'backgroundcolor');

    uicontrol('style', 'text', 'position', [30 375 250 20], 'backgroundcolor', fbg, 'string', 'Default Display Options', 'fontsize', 10, 'fontweight', 'bold', 'horizontalalignment', 'left');
    uicontrol('style', 'text', 'position', [28 347 82 20], 'string', 'Start Code', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [28 315 82 25], 'string', 'Start Offset (ms)', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [28 287 82 20], 'string', 'Duration (ms)', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'edit', 'position', [115 350 40 20], 'tag', 'start_code', 'string', UserPref.DefaultStartCode, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [115 320 40 20], 'tag', 'start_offset', 'string', UserPref.DefaultStartOffset, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [115 290 40 20], 'tag', 'duration', 'string', UserPref.DefaultDuration, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'text', 'position', [165 287 105 20], 'string', 'Smooth Window (ms)', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'edit', 'position', [275 290 40 20], 'tag', 'smooth_window', 'string', UserPref.DefaultSmoothWindow, 'backgroundcolor', [1 1 1]);

    %Data Format
    h = uicontrol('style', 'frame', 'position', [20 60 230 210]);
    fbg = get(h, 'backgroundcolor');

    uicontrol('style', 'text', 'position', [30 245 180 20], 'backgroundcolor', fbg, 'string', 'Data Format', 'fontsize', 10, 'fontweight', 'bold', 'horizontalalignment', 'left');
    uicontrol('style', 'text', 'position', [25 217 120 20], 'string', 'Start Trial Code', 'backgroundcolor', fbg', 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [25 187 120 20], 'string', 'End Trial Code', 'backgroundcolor', fbg', 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [33 155 173 20], 'string', 'Include LFP data in SPK file', 'backgroundcolor', fbg', 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [33 125 173 20], 'string', 'Use Behavioral Codes from NEX file', 'backgroundcolor', fbg', 'horizontalalignment', 'right');
    uicontrol('style', 'edit', 'position', [155 220 40 20], 'tag', 'start_trial_code', 'string', UserPref.StartTrialCode, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [155 190 40 20], 'tag', 'end_trial_code', 'string', UserPref.EndTrialCode, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'checkbox', 'position', [215 158 20 20], 'tag', 'IncludeLFP', 'value', UserPref.IncludeLFP);
    uicontrol('style', 'checkbox', 'position', [215 128 20 20], 'tag', 'UseNexCodes', 'value', UserPref.UseNexCodes);

    uicontrol('style', 'text', 'position', [30 71 140 40], 'string', 'Start Code Occurrence for merging NEX and BHV trials', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'edit', 'position', [182 87 40 20], 'tag', 'start_code_occurrence', 'string', UserPref.StartCodeOccurrence, 'backgroundcolor', [1 1 1]);

    %Analog Data Settings
    h = uicontrol('style', 'frame', 'position', [260 150 190 120]);
    fbg = get(h, 'backgroundcolor');

    t(15) = uicontrol('style', 'text','position', [270 245 150 20], 'backgroundcolor', fbg, 'string', 'Analog Data Settings', 'fontsize', 10, 'fontweight', 'bold', 'horizontalalignment', 'right');

    %Reading Data Files
    h = uicontrol('style', 'frame', 'position', [260 60 190 83]);
    fbg = get(h, 'backgroundcolor');
    t(23) = uicontrol('style', 'text', 'position', [280 121 150 20], 'string', 'Reading Data', 'fontsize', 10, 'fontweight', 'bold', 'horizontalalignment', 'center', 'backgroundcolor', fbg);
    t(24) = uicontrol('style', 'text', 'position', [285 103 140 20], 'string', 'When calling "mld_read":', 'backgroundcolor', fbg);
    t(25) = uicontrol('style', 'text', 'position', [268 82 140 20], 'string', 'Load all spikes into memory', 'backgroundcolor', fbg);
    h(18) = uicontrol('style', 'checkbox', 'position', [416 85 20 20], 'value', UserPref.LoadSpikes, 'tag', 'LoadSpikes');
    t(26) = uicontrol('style', 'text', 'position', [268 62 140 20], 'string', 'Load LFP into memory', 'horizontalalignment', 'right');
    h(19) = uicontrol('style', 'checkbox', 'position', [416 64 20 20], 'value', UserPref.LoadLFP, 'tag', 'LoadLFP');

    %Recording Locations
    h = uicontrol('style', 'frame', 'position', [340 280 110 120]);
    fbg = get(h, 'backgroundcolor');
    t(21) = uicontrol('style', 'text', 'position', [350 360 90 30], 'string', 'Recording Locations', 'fontsize', 10, 'fontweight', 'bold');
    t(22) = uicontrol('style', 'text', 'position', [350 320 90 30], 'string', 'No Location-Entry Code', 'backgroundcolor', fbg);
    h(17) = uicontrol('style', 'edit', 'position', [370 295 50 20], 'tag', 'default_no_location_code', 'string', UserPref.DefaultNoLocationCode, 'backgroundcolor', [1 1 1]);

    uicontrol('style', 'pushbutton', 'position', [120 15 230 30], 'string', 'Save Settings', 'fontsize', 10, 'fontweight', 'bold', 'tag', 'savebutton', 'callback', 'monkeywrench_config;', 'backgroundcolor', [.65 .5 .5]);
    uicontrol('style', 'pushbutton', 'position', [340 410 110 20], 'string', 'Help', 'fontsize', 8, 'tag', 'helpbutton', 'fontangle', 'italic', 'callback', 'monkeywrench_config');

    set(findobj('tag', 'LoadLFP'), 'enable', 'off'); %currently no pre-loading of LFP data; can still access from nexgetlfp.
    
    %LFP Spectrogram Preferences
    xbase = 440;
    ybase = -115;
    h = uicontrol('style', 'frame', 'position', [xbase+20 ybase+175 250 250]);
    fbg = get(h, 'backgroundcolor');
    
    uicontrol('style', 'text', 'position', [xbase+22 ybase+395 246 20], 'backgroundcolor', fbg, 'string', 'LFP Spectrogram Default Display Options', 'fontsize', 10, 'fontweight', 'bold', 'horizontalalignment', 'center');
    uicontrol('style', 'text', 'position', [xbase+25 ybase+365 100 20], 'string', 'Min Frequency', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [xbase+25 ybase+343 100 20], 'string', 'Max Frequency', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [xbase+25 ybase+321 100 20], 'string', 'Step', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [xbase+115 ybase+292 35 20], 'string', 'Min', 'backgroundcolor', fbg, 'horizontalalignment', 'center');
    uicontrol('style', 'text', 'position', [xbase+165 ybase+292 35 20], 'string', 'Max', 'backgroundcolor', fbg, 'horizontalalignment', 'center');
    uicontrol('style', 'text', 'position', [xbase+215 ybase+292 35 20], 'string', 'Use', 'backgroundcolor', fbg, 'horizontalalignment', 'center');
    uicontrol('style', 'text', 'position', [xbase+60 ybase+275 40 20], 'string', 'Theta', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [xbase+60 ybase+253 40 20], 'string', 'Delta', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [xbase+60 ybase+231 40 20], 'string', 'Alpha', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [xbase+60 ybase+209 40 20], 'string', 'Beta', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [xbase+60 ybase+187 40 20], 'string', 'Gamma', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    
    uicontrol('style', 'edit', 'position', [xbase+135 ybase+365 40 20], 'tag', 'min_frequency', 'string', LFPConfig.GlobalMinFreq, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [xbase+135 ybase+345 40 20], 'tag', 'max_frequency', 'string', LFPConfig.GlobalMaxFreq, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [xbase+135 ybase+325 40 20], 'tag', 'step', 'string', LFPConfig.FreqStep, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [xbase+115 ybase+275 40 20], 'tag', 'delta_min_frequency', 'string', LFPConfig.DeltaMin, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [xbase+165 ybase+275 40 20], 'tag', 'delta_max_frequency', 'string', LFPConfig.DeltaMax, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [xbase+215 ybase+275 40 20], 'tag', 'delta_use', 'string', LFPConfig.DeltaUse, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [xbase+115 ybase+253 40 20], 'tag', 'theta_min_frequency', 'string', LFPConfig.ThetaMin, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [xbase+165 ybase+253 40 20], 'tag', 'theta_max_frequency', 'string', LFPConfig.ThetaMax, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [xbase+215 ybase+253 40 20], 'tag', 'theta_use', 'string', LFPConfig.ThetaUse, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [xbase+115 ybase+231 40 20], 'tag', 'alpha_min_frequency', 'string', LFPConfig.AlphaMin, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [xbase+165 ybase+231 40 20], 'tag', 'alpha_max_frequency', 'string', LFPConfig.AlphaMax, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [xbase+215 ybase+231 40 20], 'tag', 'alpha_use', 'string', LFPConfig.AlphaUse, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [xbase+115 ybase+209 40 20], 'tag', 'beta_min_frequency', 'string', LFPConfig.BetaMin, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [xbase+165 ybase+209 40 20], 'tag', 'beta_max_frequency', 'string', LFPConfig.BetaMax, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [xbase+215 ybase+209 40 20], 'tag', 'beta_use', 'string', LFPConfig.BetaUse, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [xbase+115 ybase+187 40 20], 'tag', 'gamma_min_frequency', 'string', LFPConfig.GammaMin, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [xbase+165 ybase+187 40 20], 'tag', 'gamma_max_frequency', 'string', LFPConfig.GammaMax, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [xbase+215 ybase+187 40 20], 'tag', 'gamma_use', 'string', LFPConfig.GammaUse, 'backgroundcolor', [1 1 1]);
    
    
elseif ismember(gcbo, get(gcf, 'children'))
    
    callertag = get(gcbo, 'tag');
    switch callertag,
        
        case 'savebutton',

            UserPref.DefaultStartCode = str2double(get(findobj(gcf, 'tag', 'start_code'), 'string'));
            UserPref.DefaultStartOffset = str2double(get(findobj(gcf, 'tag', 'start_offset'), 'string'));
            UserPref.DefaultDuration = str2double(get(findobj(gcf, 'tag', 'duration'), 'string'));
            UserPref.DefaultSmoothWindow = str2double(get(findobj(gcf, 'tag', 'smooth_window'), 'string'));
            UserPref.StartTrialCode = str2double(get(findobj(gcf, 'tag', 'start_trial_code'), 'string'));
            UserPref.EndTrialCode = str2double(get(findobj(gcf, 'tag', 'end_trial_code'), 'string'));
            UserPref.IncludeLFP = get(findobj(gcf, 'tag', 'IncludeLFP'), 'value');
            UserPref.UseNexCodes = get(findobj(gcf, 'tag', 'UseNexCodes'), 'value');
            UserPref.LoadSpikes = get(findobj(gcf, 'tag', 'LoadSpikes'), 'value');
            UserPref.LoadLFP = get(findobj(gcf, 'tag', 'LoadLFP'), 'value');
            UserPref.StartCodeOccurrence = str2double(get(findobj(gcf, 'tag', 'start_code_occurrence'), 'string'));
            UserPref.DefaultNoLocationCode = str2double(get(findobj(gcf, 'tag', 'default_no_location_code'), 'string'));
                     
            
            LFPConfig.GlobalMinFreq = str2double(get(findobj(gcf, 'tag', 'min_frequency'), 'string'));
            LFPConfig.GlobalMaxFreq = str2double(get(findobj(gcf, 'tag', 'max_frequency'), 'string'));
            LFPConfig.FreqStep = str2double(get(findobj(gcf, 'tag', 'step'), 'string'));
            LFPConfig.ThetaMin = str2double(get(findobj(gcf, 'tag', 'theta_min_frequency'), 'string'));
            LFPConfig.ThetaMax = str2double(get(findobj(gcf, 'tag', 'theta_max_frequency'), 'string'));
            LFPConfig.DeltaMin = str2double(get(findobj(gcf, 'tag', 'delta_min_frequency'), 'string'));
            LFPConfig.DeltaMax = str2double(get(findobj(gcf, 'tag', 'delta_max_frequency'), 'string'));
            LFPConfig.AlphaMin = str2double(get(findobj(gcf, 'tag', 'alpha_min_frequency'), 'string'));
            LFPConfig.AlphaMax = str2double(get(findobj(gcf, 'tag', 'alpha_max_frequency'), 'string'));
            LFPConfig.BetaMin = str2double(get(findobj(gcf, 'tag', 'beta_min_frequency'), 'string'));
            LFPConfig.BetaMax = str2double(get(findobj(gcf, 'tag', 'beta_max_frequency'), 'string'));
            LFPConfig.GammaMin = str2double(get(findobj(gcf, 'tag', 'gamma_min_frequency'), 'string'));
            LFPConfig.GammaMax = str2double(get(findobj(gcf, 'tag', 'gamma_max_frequency'), 'string'));
            LFPConfig.DeltaUse = str2double(get(findobj(gcf, 'tag', 'delta_use'), 'string'));
            LFPConfig.ThetaUse = str2double(get(findobj(gcf, 'tag', 'theta_use'), 'string'));
            LFPConfig.AlphaUse = str2double(get(findobj(gcf, 'tag', 'alpha_use'), 'string'));
            LFPConfig.BetaUse = str2double(get(findobj(gcf, 'tag', 'beta_use'), 'string'));
            LFPConfig.GammaUse = str2double(get(findobj(gcf, 'tag', 'gamma_use'), 'string'));

            UserPref.LFPSpectrogram = LFPConfig;
            
            setpref('MonkeyLogic', 'UserPreferences', UserPref);
            disp('Updated MonkeyLogic User Preferences');

        case 'helpbutton',

            %web http://www.mit.edu/~wfasaad/spkguide/configmenu.html
            
    end

end


