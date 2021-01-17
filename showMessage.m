% Copyright (c) 2021 Yuta Suzuki
% This software is released under the MIT License, see LICENSE.

function showMessage(cfg,myText1,myText2,screenNumber,win)

TextColor=[0 0 0];
message = Screen('OpenOffscreenWindow',screenNumber,cfg.BGCOLOR);
Screen('TextSize', message, 30);
Screen('TextFont', message, 'Times New Roman');
DrawFormattedText(message, myText1, 'center', cfg.rect(2)-20, TextColor);
if ~isempty(myText2)
    DrawFormattedText(message, myText2, 'center', cfg.rect(2)+30, TextColor);
end

Screen('CopyWindow',message,win);
Screen('Flip', win);
pause(0.5);

% Enter to start
while 1
    clear keyCode;
    [keyIsDown,secs,keyCode]=KbCheck;
    if (keyCode(cfg.KEYNAME.returnKey) )
        break;
    end
    % ESCEPE
    if (keyCode(cfg.KEYNAME.escapeKey) )
        Screen('CloseAll');
        Screen('ClearAll');
        ListenChar(0);
        return
    end
end
end

