function [] = plotxy(new_center1, new_center, countFrame)

if (max(new_center) ~=0 )

  u = find(new_center == min(new_center(:,1)),1);
  mincenter = new_center(u,:);
  v = find(new_center1 == min(new_center1(:,1)),1);
  mincenter1= new_center1(v,:);
    
  dis =  mincenter- mincenter1;

    figure(3);
    
    subplot(1, 2, 1);
    hold on;
    title('Saturation Axis X');
    xlabel('t');
    ylabel('Saturation');
    grid on;
    xlim([0, 500]);
    ylim([-50, 50]);
    
     
    plot(countFrame, dis(1), 'o', 'LineWidth', 2);
    
    subplot(1, 2, 2);
    hold on;
    title('Saturation Axis Y');
    xlabel('t');
    ylabel('Saturation');
    grid on;
     xlim([0, 500]);
    ylim([-50, 50]);
    
    plot(countFrame, dis(2), 'o', 'LineWidth', 2);
    
    drawnow;
    pause(0.01);
% else 
%      figure(3);
% 
%     subplot(1, 2, 1);
%     hold on;
%     title('Saturation Axis X');
%     xlabel('t');
%     ylabel('Saturation');
%     grid on;
%     xlim([0, 1000]);
%     ylim([-50, 50]);
% 
%     plot(countFrame, 0 , 'o', 'LineWidth', 2);
% 
%     subplot(1, 2, 2);
%     hold on;
%     title('Saturation Axis Y');
%     xlabel('t');
%     ylabel('Saturation');
%     grid on;
%     xlim([0, 1000]);
%     ylim([-50, 50]);
% 
%     plot(countFrame,0, 'o', 'LineWidth', 2);
% 
%     drawnow;
%     pause(0.01);
end
end
