clc; 
clear;
close all;

video = VideoReader('video3.mp4');

x0 = 50;
y0 = 290;
deltax = 330;
deltay = 150;
merhak = 105;
rate = video.FrameRate;
numf =video.NumFrames ;
countFrame = 2 ;
countblink = 0 ;
new_center = 0;
new_rad = 0;
VT = video.CurrentTime;


  videoframeg1 = read(video,1);
  roi1 = imcrop(videoframeg1, [x0 y0 deltax deltay]);
  [new_center,new_rad,countblink,roi1] = find_eyes(merhak,roi1,countblink,6);


new_center1 = new_center;
new_rad1 = new_rad;


while hasFrame(video)   %% read

  videoframeg = read(video,countFrame); %%% read frames
  countFrame = countFrame + 10 ; 
  roi1 = imcrop(videoframeg, [x0 y0 deltax deltay]); %%%croping

   [new_center,new_rad,countblink,roi1] = find_eyes(merhak,roi1,countblink,6); %find the eyes 
     % figure(1);
    % countblink =  prontFrame(roi1,new_rad,new_center,countblink);%%% print the frime with the circles


 if countFrame >= numf    %%%  condition to break
      countFrame = numf;
     close all;

    break;


 end
end


new_center = [0,0;0,0];
new_rad = [0,0];
countFrame =1;
countblink =0;

x01 = abs(new_center1(1,1)-new_center1(2,1))/2+ min(new_center1(:,1));

y01 = abs(new_center1(1,2)-new_center1(1,2))/2+ min(new_center1(:,2));

while hasFrame(video)
     videoframeg = read(video,countFrame); %%%  
     roi1 = imcrop(videoframeg, [x0 y0 deltax deltay]);
     countFrame = countFrame + 10;

     [new_center,new_rad,countblink,roi1] = find_eyes(merhak,roi1,countblink,6);

      roi1 = tranlate(new_center,new_rad,roi1,x01,y01);

      [new_center,new_rad,countblink,roi1] = find_eyes(merhak,roi1,countblink,6);

      figure(2);
       countblink =  prontFrame(roi1,new_rad,new_center,countblink);



      if countFrame >= numf
      countFrame = numf;
      close all;
    break;

    end

     % plotxy(new_center1,new_center,countFrame);

end

