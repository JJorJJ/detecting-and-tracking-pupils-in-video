classdef PupilTrackingApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure             matlab.ui.Figure
        StartButton          matlab.ui.control.Button
        StopButton           matlab.ui.control.Button
        AxesDisplay          matlab.ui.control.UIAxes
        % AxesGraph            matlab.ui.control.UIAxes
        StatusLabel          matlab.ui.control.Label
    end

    properties (Access = private)
        IsRunning logical = false; % Control for starting/stopping the loop
        Video  % Video object
        CountFrame double = 2; % Frame counter
        CountBlink double = 0; % Blink counter
        X0 double = 50; % ROI parameters
        Y0 double = 290;
        DeltaX double = 330;
        DeltaY double = 150;
        Merhak double = 105;
        NewCenter double = 0;
        NewRad double = 0;
        NewCenter1 double = 0;
        NewRad1 double = 0;
    end

    methods (Access = private)

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            % Set running state to true
            app.IsRunning = true;
            app.StatusLabel.Text = 'Processing...';

            % Initialize video
            app.Video = VideoReader('video3.mp4');
            app.CountFrame = 2;
            app.CountBlink = 0;

            % Process first frame
            videoframeg1 = read(app.Video, 1);
            roi1 = imcrop(videoframeg1, [app.X0 app.Y0 app.DeltaX app.DeltaY]);
            [app.NewCenter, app.NewRad, app.CountBlink, roi1] = find_eyes(app.Merhak, roi1, app.CountBlink, 6);

            app.NewCenter1 = app.NewCenter;
            app.NewRad1 = app.NewRad;

            % Main processing loop
            while hasFrame(app.Video) && app.IsRunning
                % Read and process frame
                videoframeg = read(app.Video, app.CountFrame);
                app.CountFrame = app.CountFrame + 10;
                roi1 = imcrop(videoframeg, [app.X0 app.Y0 app.DeltaX app.DeltaY]);

                [app.NewCenter, app.NewRad, app.CountBlink, roi1] = find_eyes(app.Merhak, roi1, app.CountBlink, 6);

                % Display processed frame
                imshow(roi1, 'Parent', app.AxesDisplay);
                if max(app.NewCenter) > 0
                    hold(app.AxesDisplay, 'on');
                    viscircles(app.AxesDisplay, app.NewCenter, app.NewRad, 'EdgeColor', 'r');
                    hold(app.AxesDisplay, 'off');
                end



                % Update ROI using tranlate
                x01 = abs(app.NewCenter1(1, 1) - app.NewCenter1(2, 1)) / 2 + min(app.NewCenter1(:, 1));
                y01 = abs(app.NewCenter1(1, 2) - app.NewCenter1(1, 2)) / 2 + min(app.NewCenter1(:, 2));
                roi1 = tranlate(app.NewCenter, app.NewRad, roi1, x01, y01);
                [app.NewCenter, app.NewRad, app.CountBlink, roi1] = find_eyes(app.Merhak, roi1, app.CountBlink, 6);

                % Update graph
                plotxy(app.NewCenter1, app.NewCenter, app.CountFrame);

                % Stop condition
                if app.CountFrame >= app.Video.NumFrames
                    app.IsRunning = false;
                end

                pause(1 / app.Video.FrameRate);
            end

            % Update status label
            app.StatusLabel.Text = 'Processing Complete';
        end

        % Button pushed function: StopButton
        function StopButtonPushed(app, event)
            app.IsRunning = false;
            app.StatusLabel.Text = 'Stopped';
        end

    end

    % Helper functions for processing
    methods (Access = private)

        function [new_center, new_rad, countblink, roi1] = find_eyes(~, merhak, roi1, countblink, p)
            % Logic from find_eyes function
            new_center = 0;
            new_rad = 0;

            g = p;
            [center, radii] = imfindcircles(roi1, [g, 10], "ObjectPolarity", "dark", "Sensitivity", 0.94);
            f = (size(radii, 1));

            if f > 1
                ma = max(center(:, 2));
                for i = 1:f
                    for j = 1:f
                        if (i + j > f)
                            j = f;
                        else
                            if center(i, 2) < (center(i + j, 2) * 1.1) && center(i, 2) > (center(i + j, 2) * 0.9) && center(i, 2) > ma * 0.88 && abs(center(i, 1) - center(i + j, 1)) > merhak / 2
                                new_center = [center(i, 1), center(i, 2); center(i + j, 1), center(i + j, 2)];
                                new_rad = [radii(i), radii(i + j)];
                                i = f;
                                j = f;
                            end
                        end
                    end
                end
            else
                countblink = countblink + 1;
            end
        end

        % function roi1 = tranlate(~, new_center, new_rad, roi1, x01, y01, merhak)
        %     b = length(new_rad);
        % 
        %     if b == 2
        %         Xmiddleofeyes = abs(new_center(2, 1) - new_center(1, 1)) / 2;
        %         Xleft_Eye = min(new_center(:, 1));
        %         Xpn_middle = Xleft_Eye + Xmiddleofeyes;
        %         Xp1_middle = x01;
        %         dx = (Xp1_middle - Xpn_middle);
        % 
        %         Ymiddleofeyes = abs(new_center(2, 2) - new_center(1, 2)) / 2;
        %         Yleft_Eye = min(new_center(:, 2));
        %         Ypn_middle = Yleft_Eye + Ymiddleofeyes;
        %         Yp1_middle = y01;
        %         dy = (Yp1_middle - Ypn_middle);
        % 
        %         roi1 = imtranslate(roi1, [dx, dy], 'cubic', 'FillValues', 255);
        %     end
        % end

    %     function plotxy(~, new_center1, new_center, countFrame, axesHandle)
    %         b = length(new_center(:, 1));
    %         if b > 1
    %             dis = new_center1 - new_center;
    %             hold(axesHandle, 'on');
    %             view(2);
    %             plot(axesHandle, countFrame, min(dis(:, 2)), '-o', 'LineWidth', 2);
    %             grid(axesHandle, 'on');
    %             hold(axesHandle, 'off');
    %         end
    %     end
    % 
     end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 800 600];
            app.UIFigure.Name = 'Pupil Tracking App';

            % Create StartButton
            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.Position = [50 50 100 30];
            app.StartButton.Text = 'Start';
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);

            % Create StopButton
            app.StopButton = uibutton(app.UIFigure, 'push');
            app.StopButton.Position = [200 50 100 30];
            app.StopButton.Text = 'Stop';
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);

            % Create AxesDisplay
            app.AxesDisplay = uiaxes(app.UIFigure);
            app.AxesDisplay.Position = [50 100 700 500];
            title(app.AxesDisplay, 'Video Display');

            % % Create AxesGraph
            % app.AxesGraph = uiaxes(app.UIFigure);
            % app.AxesGraph.Position = [450 150 300 400];
            % title(app.AxesGraph, 'Graph Display');

            % Create StatusLabel
            app.StatusLabel = uilabel(app.UIFigure);
            app.StatusLabel.Position = [350 50 300 30];
            app.StatusLabel.Text = 'Status: Ready';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = PupilTrackingApp

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure);
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
