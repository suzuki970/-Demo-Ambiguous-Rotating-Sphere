% Copyright (c) 2021 Yuta Suzuki
% This software is released under the MIT License, see LICENSE.

function pixel_num = pixel_size(dotpitch, visual_angle , visual_range)

% dotpitch = 0.282; %(mm) SMI
% visual_angle = 0.29 %(?�)
% visual_range = 60 %(cm)

visual_angle = visual_angle * (pi/180);   % Degree to radian
a = visual_range * tan(visual_angle); % output = ?�?�cm
a = a * 10;  % cm to mm
disp([num2str(a),'mm'])
pixel_num = a / dotpitch;
end