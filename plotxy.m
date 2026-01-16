function [] = plotxy(new_center1,new_center,countFrame)

a = length(size(new_center));

if  a ~= 0

  dis =  min(new_center1(:,:))-min(new_center(:,:));
 
  figure(3);
   hold on;
   view(2);
   subplot(1,2,1);
   h =   plot(nan,nan,'-o','LineWidth',2);
   title('satoration axis x');
   xlabel('t');
   ylabel('satoration');
       hold on;
       grid on;
      xlim([0, 1000]);
      ylim([-10,10]);
       set(h,'XData', countFrame,'YData',dis(1));
     drawnow;
     pause(0.01);
     
        
  
     subplot(1,2,2);
     h = plot(nan,nan,'-o','LineWidth',2);
     title('satoration axis y');
     xlabel('t');
     ylabel('satoration');
     grid on;
     hold on;
     xlim([0, 1000]);
     ylim([-10,10]);
     set(h,'XData', countFrame,'YData',dis(2));
     drawnow;
     pause(0.01);
  
      

end
end

