function [ new_center, new_rad,countblink,roi1] = find_eyes(merhak,roi1,countblink,p)


  new_center = 0;
     new_rad = 0;

 g = p ; %%% minimun radius
 
 [center,radii] = imfindcircles( roi1,[g,10],"ObjectPolarity","dark","Sensitivity",0.945);  %%% מציאת עיגולים בתמונה
 f = (size(radii,1));
 if f > 1 %% only for 2 cyceles and more

 %%find eyes
ma = max(center(:,2)); %   הערך בציר Y  שנותן את העיגול הכי נמוך 

   for i=1:f   %%%%%% ריצה על כל 2 עיגולים שהתקבלו כדי לסווג מה הם העיניים 
    for j=1:f 
      if (i+j > f)
        j =  f ;
      else  if center(i,2) < (center(i+j,2)*1.1) && center(i,2) > (center(i+j,2)*0.9) &&  center(i,2) > ma*0.88 && abs(center(i,1)-center(i+j,1))> merhak/2 && abs(center(i,1)-center(i+j,1)) < merhak*1.5
       new_center = [center(i,1),center(i,2);center(i+j,1),center(i+j,2)];
       new_rad = [radii(i),radii(i+j)];
       break;
    end
    end
  end
  end
             

 else
     countblink = countblink+1;
      new_center = [0,0];
 end
end
