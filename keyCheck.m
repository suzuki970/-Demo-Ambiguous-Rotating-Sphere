function keyCheck
KbName('UnifyKeyNames');
tic;
while toc < 1; end;
DisableKeysForKbCheck([]);
[ keyIsDown, secs, keyCode ] = KbCheck;
if keyIsDown 
    keys=find(keyCode)
    KbName(keys)
    DisableKeysForKbCheck(keys);
end