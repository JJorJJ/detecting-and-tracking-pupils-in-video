function [roi1] = tranlate(new_center,new_rad,roi1,x01,y01)

b = length(new_rad);

      if   b  == 2 

      Xmiddleofeyes =abs(new_center(2,1)-new_center(1,1))/2;
     
      Xleft_Eye = min(new_center(:,1));
      Xpn_middle = Xleft_Eye + Xmiddleofeyes;
      Xp1_middle = x01;
      dx = (Xp1_middle-Xpn_middle);

      Ymiddleofeyes =abs(new_center(2,2)-new_center(1,2))/2;
       Yleft_Eye = min(new_center(:,2));
       Ypn_middle = Yleft_Eye + Ymiddleofeyes;
       Yp1_middle = y01;
        dy = (Yp1_middle-Ypn_middle);

     roi1 = imtranslate(roi1,[dx,dy],'cubic','FillValues',255);

      end

   end