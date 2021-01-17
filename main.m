%%%%%%%%%% description %%%%%%%%%%%%%%
% Created on Tue Mar 31 2020
% Place : Japan,
% Author : Yuta Suzuki

% Eye-tracker     : EyeLink
% Display         : Display++
% Visual distance : 80 cm

% Copyright (c) 2021 Yuta Suzuki
% This software is released under the MIT License, see LICENSE.
%% -----------------------------------

clear all;
close all;
Screen('Close')
Screen('Preference', 'SkipSyncTests', 1);
rng('shuffle');

% OpenGL
AssertOpenGL;

% participant's info
% prompt = 'Demo? (yes:1 / no:2) --> ';
% demoMode =input(prompt);
%
% prompt = 'Name? ----> ';
% participantsInfo.name = input(prompt,'s');
% prompt = 'Age? ----> ';
% participantsInfo.age = input(prompt,'s');

today_date = datestr(now, 30);

% hide a cursor point
HideCursor;
ListenChar(2);
myKeyCheck;


%% time parameters setup
cfg = [];

cfg.TIME_ISI  = 0;   % ISI
cfg.TIME_STIM = 6;   % for 1 rotation[sec]
cfg.TIME_PRESENTATION = 6;  % for entire presentation[sec]
cfg.TIME_FIX  = 5;   % fixation time[sec]

cfg.VISUAL_DISTANCE = 80;
cfg.FRAME_RATE = 60;
cfg.DOT_PITCH = 0.369;  % 32 inch, 1920 x 1080 pixels size

%% RDK parameters setup
cfg.RADIUS = round( pixel_size(cfg.DOT_PITCH, 5.5, cfg.VISUAL_DISTANCE) ); % radius
cfg.DOTS_NUM = 500; % number of dots
cfg.DOTS_SIZE = [pixel_size(cfg.DOT_PITCH, 0.29, cfg.VISUAL_DISTANCE)...
    pixel_size(cfg.DOT_PITCH, 0.14, cfg.VISUAL_DISTANCE)] ; % dots size
cfg.DOTS_COLOR = [255 40]; % dots color forward to [left right]

%% Key setup
cfg.KEYNAME = [];
cfg.KEYNAME.escapeKey = KbName('q');
cfg.KEYNAME.returnKey = KbName('a');
cfg.KEYNAME.NumKey4 = KbName('4');
cfg.KEYNAME.NumKey6 = KbName('6');

% background luminance (default=128)
rgb = 128;
cfg.BGCOLOR = [rgb rgb rgb];

%% screen setup
screens=Screen('Screens');
screenNumber = max(screens);

% main window
[win, rect] = Screen('OpenWindow',screenNumber, cfg.BGCOLOR);
[centerX centerY] = RectCenter(rect);
cfg.rect = [centerX centerY];

% empty
empty=Screen('OpenOffscreenWindow',screenNumber,cfg.BGCOLOR, [],[],32);

% fixation
fix = Screen('OpenOffscreenWindow',screenNumber, cfg.BGCOLOR, [],[],32);
fixlength = pixel_size( cfg.DOT_PITCH, 0.3, cfg.VISUAL_DISTANCE);
FixationXY = [centerX-1*fixlength, centerX+fixlength, centerX, centerX; centerY, centerY, centerY-1*fixlength, centerY+fixlength];
cfg.FIXCOLOR=[0 0 0];
Screen('DrawLines', fix, FixationXY,2, cfg.FIXCOLOR);

% flips for RDK
for i = 1 : cfg.FRAME_RATE*cfg.TIME_STIM
    [window_dots(i),screenRect] = Screen('OpenOffscreenWindow',screenNumber,cfg.BGCOLOR, [],[],32);
end

%% RDK parameter

% definition of the circles location(i.e. a width of each dot's lane)
x = linspace(-1,0,cfg.DOTS_NUM);
init_r = x.^3;
init_r = init_r / max(abs(init_r)) * cfg.RADIUS +cfg.RADIUS;

% initialization
init_angle = rand(1,cfg.DOTS_NUM) * 2 * pi;
parm_dots = zeros( 4, cfg.DOTS_NUM, 1 ); % 1:x, 2:y, 3:theta, 4:previous x, 5:previous location

theta = (360/cfg.TIME_STIM/cfg.FRAME_RATE) * pi / 180;

for i = 1:cfg.DOTS_NUM
    parm_dots(1, i) = init_r(1, i) * cos( init_angle(1, i) );
    parm_dots(2, i) = init_r(1, i) * sin( init_angle(1, i) );
    parm_dots(3, i) = init_angle(1, i);
    parm_dots(4, i) = init_r(1, i);
end

%% calculation of the dot's coordinate
rand_dotsCol = randperm(cfg.DOTS_NUM);
for i = 1 : cfg.FRAME_RATE*cfg.TIME_STIM
    
    for dots_count = 1 : cfg.DOTS_NUM
        parm_dots(5, dots_count) = parm_dots(1, dots_count); % previous coordinate of x
        parm_dots(1, dots_count) = real(parm_dots(4, dots_count) * cos( parm_dots(3, dots_count) + theta )); % x Coordinate
        parm_dots(2, dots_count) = real(parm_dots(4, dots_count) * sin( parm_dots(3, dots_count) + theta )); % y Coordinate
        parm_dots(3, dots_count) = parm_dots(3, dots_count) + theta; % update the value of theta
        rn = sqrt( parm_dots(1, dots_count)^2 + parm_dots(2, dots_count)^2);
        
        if mod(dots_count,2) == 0
            parm_dots(2, dots_count) = real(-sqrt(cfg.RADIUS^2 - rn^2));
        else
            parm_dots(2, dots_count) = real(sqrt(cfg.RADIUS^2 - rn^2));
        end
    end
    parm_dots(6,rand_dotsCol) = repelem([0 1],cfg.DOTS_NUM/2);
    
    Screen('BlendFunction', window_dots(i), 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    t1 =  find(parm_dots(5, :) > parm_dots(1, :)==1);  % move to left
    t2 =  find(parm_dots(5, :) <= parm_dots(1, :)==1); % move to right
    for layerRoop = 0:1
        ind1 = find(parm_dots(6, t1) == layerRoop); % 1st layer
        ind2 = find(parm_dots(6, t2) == layerRoop); % 2nd layer
        
        dCol  = repmat(repelem([cfg.DOTS_COLOR(1) cfg.DOTS_COLOR(2)],[size(ind1,2) size(ind2,2)]),3,1); % dots color
        dSize = repelem([cfg.DOTS_SIZE(1) cfg.DOTS_SIZE(2)],[size(ind1,2) size(ind2,2)]); % dots size
        Screen('DrawDots',  window_dots(i), parm_dots(1:2,[t1(ind1) t2(ind2)]), dSize, dCol, [rect(3:4)/2], 1);
    end
end

showMessage(cfg,'Ready...',[],screenNumber,win);

%% presentation
for flick_roop = 1:round(cfg.TIME_PRESENTATION/cfg.TIME_STIM)
    
    for i = 1 : cfg.FRAME_RATE*cfg.TIME_STIM
        Screen('CopyWindow',window_dots(i),win);
        
        Screen('Flip', win,0,1);
        
        imageArray=Screen('GetImage',window_dots(i));
        if i < 10
            imwrite(imageArray,['test00' num2str(i) '.png']);
        elseif i > 9 && i < 100
            imwrite(imageArray,['test0' num2str(i) '.png']);
        else
            imwrite(imageArray,['test' num2str(i) '.png']);
        end
        
        [ keyIsDown, seconds, keyCode ] = KbCheck;
        if keyCode(cfg.KEYNAME.escapeKey) || keyCode(cfg.KEYNAME.returnKey)
            if keyCode(cfg.KEYNAME.escapeKey)
                Screen('CloseAll');
                Screen('ClearAll');
                ListenChar(0);
                return
            end
        end
    end
end

sca;
ListenChar(0);
fprintf('********* Finish **********\n')