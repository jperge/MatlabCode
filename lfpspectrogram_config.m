function [LFPConfig, f] = lfpspectrogram_config(varargin)
% To be called when ~ispref('MonkeyLogic', 'LFPSpectrogramPref');
%
% created 7/3/2012 -Max Ladow


if ~ispref('MonkeyLogic', 'LFPSpectrogramPrefences'),
    LFPConfig.DefaultMinFrequency = 0;
    LFPConfig.DefaultMaxFrequency = 70;
    LFPConfig.DefaultStep = 3;
    LFPConfig.DefaultDeltaMinFrequency = 0;
    LFPConfig.DefaultThetaMinFrequency = 4;
    LFPConfig.DefaultAlphaMinFrequency = 8;
    LFPConfig.DefaultBetaMinFrequency = 14;
    LFPConfig.DefaultGammaMinFrequency = 30;
    LFPConfig.DefaultDeltaMaxFrequency = 4;
    LFPConfig.DefaultThetaMaxFrequency = 8;
    LFPConfig.DefaultAlphaMaxFrequency = 14;
    LFPConfig.DefaultBetaMaxFrequency = 30;
    LFPConfig.DefaultGammaMaxFrequency = 70;
    LFPConfig.DeltaUse = 1;
    LFPConfig.ThetaUse = 1;
    LFPConfig.AlphaUse = 1;
    LFPConfig.BetaUse = 1;
    LFPConfig.GammaUse = 1;
    
    setpref('MonkeyLogic', 'LFPSpectrogramPreferences', LFPConfig);
else
    LFPConfig = getpref('MonkeyLogic', 'LFPSpectrogramPreferences');
end

f = findobj('tag', 'LFPPreferences');
if ~isempty(f),
    figure(f);
end

if isempty(f),
    figure;
    set(gcf, 'numbertitle', 'off', 'name', 'LFPSpectrogram User Preferences', 'menubar', 'none', 'position', [200 100 460 450], 'tag', 'LFPPreferences');
    bg = get(gcf, 'color');
    
    %LFP Frequency Default Display Options
    h = uicontrol('style', 'frame', 'position', [20 145 350 300]);
    fbg = get(h, 'backgroundcolor');
    
    uicontrol('style', 'text', 'position', [30 395 250 20], 'backgroundcolor', fbg, 'string', 'LFP Frequency Default Display Options', 'fontsize', 10, 'fontweight', 'bold', 'horizontalalignment', 'left');
    uicontrol('style', 'text', 'position', [28 365 90 20], 'string', 'Min Frequency', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [28 343 90 20], 'string', 'Max Frequency', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [38 321 40 20], 'string', 'Step', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [115 298 25 20], 'string', 'Min', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [165 298 30 20], 'string', 'Max', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [215 298 30 20], 'string', 'Use', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [36 275 36 20], 'string', 'Theta', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [36 253 36 20], 'string', 'Delta', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [36 231 36 20], 'string', 'Alpha', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [36 209 36 20], 'string', 'Beta', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    uicontrol('style', 'text', 'position', [36 187 40 20], 'string', 'Gamma', 'backgroundcolor', fbg, 'horizontalalignment', 'right');
    
    uicontrol('style', 'edit', 'position', [135 365 40 20], 'tag', 'min_frequency', 'string', LFPConfig.DefaultMinFrequency, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [135 345 40 20], 'tag', 'max_frequency', 'string', LFPConfig.DefaultMaxFrequency, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [135 325 40 20], 'tag', 'step', 'string', LFPConfig.DefaultStep, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [115 275 40 20], 'tag', 'delta_min_frequency', 'string', LFPConfig.DefaultDeltaMinFrequency, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [165 275 40 20], 'tag', 'delta_max_frequency', 'string', LFPConfig.DefaultDeltaMaxFrequency, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [215 275 40 20], 'tag', 'delta_use', 'string', LFPConfig.DeltaUse, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [115 253 40 20], 'tag', 'theta_min_frequency', 'string', LFPConfig.DefaultThetaMinFrequency, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [165 253 40 20], 'tag', 'theta_max_frequency', 'string', LFPConfig.DefaultThetaMaxFrequency, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [215 253 40 20], 'tag', 'theta_use', 'string', LFPConfig.ThetaUse, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [115 231 40 20], 'tag', 'alpha_min_frequency', 'string', LFPConfig.DefaultAlphaMinFrequency, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [165 231 40 20], 'tag', 'alpha_max_frequency', 'string', LFPConfig.DefaultAlphaMaxFrequency, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [215 231 40 20], 'tag', 'alpha_use', 'string', LFPConfig.AlphaUse, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [115 209 40 20], 'tag', 'beta_min_frequency', 'string', LFPConfig.DefaultBetaMinFrequency, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [165 209 40 20], 'tag', 'beta_max_frequency', 'string', LFPConfig.DefaultBetaMaxFrequency, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [215 209 40 20], 'tag', 'beta_use', 'string', LFPConfig.BetaUse, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [115 187 40 20], 'tag', 'gamma_min_frequency', 'string', LFPConfig.DefaultGammaMinFrequency, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [165 187 40 20], 'tag', 'gamma_max_frequency', 'string', LFPConfig.DefaultGammaMaxFrequency, 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [215 187 40 20], 'tag', 'gamma_use', 'string', LFPConfig.GammaUse, 'backgroundcolor', [1 1 1]);
    
    uicontrol('style', 'pushbutton', 'position', [60 100 230 30], 'string', 'Save Settings', 'fontsize', 10, 'fontweight', 'bold', 'tag', 'savebutton', 'callback', 'lfpspectrogram_config;', 'backgroundcolor', [.65 .5 .5]);
    
elseif ismember(gcbo, get(gcf, 'children'))
    
    callertag = get(gcbo, 'tag');
    switch callertag,
        %saves updated preferences
        case 'savebutton',
            
            LFPConfig.DefaultMinFrequency = str2double(get(findobj(gcf, 'tag', 'min_frequency'), 'string'));
            LFPConfig.DefaultMaxFrequency = str2double(get(findobj(gcf, 'tag', 'max_frequency'), 'string'));
            LFPConfig.DefaultStep = str2double(get(findobj(gcf, 'tag', 'step'), 'string'));
            LFPConfig.DefaultThetaMinFrequency = str2double(get(findobj(gcf, 'tag', 'theta_min_frequency'), 'string'));
            LFPConfig.DefaultThetaMaxFrequency = str2double(get(findobj(gcf, 'tag', 'theta_max_frequency'), 'string'));
            LFPConfig.DefaultDeltaMinFrequency = str2double(get(findobj(gcf, 'tag', 'delta_min_frequency'), 'string'));
            LFPConfig.DefaultDeltaMaxFrequency = str2double(get(findobj(gcf, 'tag', 'delta_max_frequency'), 'string'));
            LFPConfig.DefaultAlphaMinFrequency = str2double(get(findobj(gcf, 'tag', 'alpha_min_frequency'), 'string'));
            LFPConfig.DefaultAlphaMaxFrequency = str2double(get(findobj(gcf, 'tag', 'alpha_max_frequency'), 'string'));
            LFPConfig.DefaultBetaMinFrequency = str2double(get(findobj(gcf, 'tag', 'beta_min_frequency'), 'string'));
            LFPConfig.DefaultBetaMaxFrequency = str2double(get(findobj(gcf, 'tag', 'beta_max_frequency'), 'string'));
            LFPConfig.DefaultGammaMinFrequency = str2double(get(findobj(gcf, 'tag', 'gamma_min_frequency'), 'string'));
            LFPConfig.DefaultGammaMaxFrequency = str2double(get(findobj(gcf, 'tag', 'gamma_max_frequency'), 'string'));
            LFPConfig.DeltaUse = str2double(get(findobj(gcf, 'tag', 'delta_use'), 'string'));
            LFPConfig.ThetaUse = str2double(get(findobj(gcf, 'tag', 'theta_use'), 'string'));
            LFPConfig.AlphaUse = str2double(get(findobj(gcf, 'tag', 'alpha_use'), 'string'));
            LFPConfig.BetaUse = str2double(get(findobj(gcf, 'tag', 'beta_use'), 'string'));
            LFPConfig.GammaUse = str2double(get(findobj(gcf, 'tag', 'gamma_use'), 'string'));
            
            setpref('MonkeyLogic', 'LFPSpectrogramPreferences', LFPConfig);
            disp('Updated LFPSpectrogram User Preferences')
            
    end
    
end


