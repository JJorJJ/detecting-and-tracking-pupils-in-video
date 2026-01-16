function [new_center, new_rad, countblink, roi1] = find_eyes(merhak, roi1, countblink, p)

new_center = [0, 0];
new_rad = [0, 0];

g=p;
[center, radii] = imfindcircles(roi1, [g, 10], "ObjectPolarity", "dark", "Sensitivity", 0.935);
f = size(radii, 1);

if f > 1
    ma = max(center(:, 2));

    for i = 1:f
        for j = 1:f
            if (i + j > f)
                j = f;
            else
                if center(i, 2) < (center(i + j, 2) * 1.1) && ...
                   center(i, 2) > (center(i + j, 2) * 0.9) && ...
                   center(i, 2) > ma * 0.88 && ...
                   abs(center(i, 1) - center(i + j, 1)) > merhak / 2 && ...
                   abs(center(i, 1) - center(i + j, 1)) < merhak * 1.5

                   new_center = [center(i,1), center(i,2); center(i+j,1), center(i+j,2)];
                   new_rad = [radii(i), radii(i + j)];
                   return;
                end
            end
        end
    end
else
    countblink = countblink + 1;
    new_center = [0, 0; 0, 0];
end
end
