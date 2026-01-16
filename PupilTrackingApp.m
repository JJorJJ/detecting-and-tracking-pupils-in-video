classdef PupilTrackingApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure             matlab.ui.Figure  % UI main figure
        StartButton          matlab.ui.control.Button  % Start button
        StopButton           matlab.ui.control.Button  % Stop button
        AxesDisplay          matlab.ui.control.UIAxes  % Axes for video display
        StatusLabel          matlab.ui.control.Label  % Status label
    end

    properties (Access = private)
        IsRunning logical = false;  % Control flag for processing loop
        Video  % Video file reader
        CountFrame double = 2;  % Frame counter
        CountBlink double = 0;  % Blink counter
        Merhak double = 130;  % Threshold for eye distance
        NewCenter double = 0;  % Current detected eye center
        NewRad double = 0;  % Current detected eye radius
        NewCenter1 double = 0;  % Previous detected eye center
        NewRad1 double = 0;  % Previous detected eye radius
        EyebrowCenter double = [0, 0];  % Current detected eyebrow center
        EyebrowCenter1 double = [0, 0];  % Previous detected eyebrow center
    end

    methods (Access = private)
        function StartButtonPushed(app, event)
            app.IsRunning = true;
            app.StatusLabel.Text = 'Processing...';

            % Load video file
            app.Video = VideoReader('video1.mp4');
            app.CountFrame = 2;
            app.CountBlink = 0;

            faceDetector = vision.CascadeObjectDetector();  % Face detector initialization
            
            % Read initial frame and detect face
            videoframeg1 = read(app.Video, 2);
            bboxes = faceDetector(videoframeg1);
            
            if isempty(bboxes)
                app.StatusLabel.Text = 'No face detected in first frame';
                app.IsRunning = false;
                return;
            end
            
            bbox = bboxes(1, :);  % Extract face bounding box
            eyeRegionY = bbox(2) + round(bbox(4) * 0.15);  % Define eye region
            eyeRegionHeight = round(bbox(4) * 0.35);
            roi1 = imcrop(videoframeg1, [bbox(1), eyeRegionY, bbox(3), eyeRegionHeight]);
            
            % Detect eyes and eyebrows in first frame
            [app.NewCenter, app.NewRad, app.CountBlink, roi1] = find_eyes(app.Merhak, roi1, app.CountBlink, 5);
            app.EyebrowCenter1 = find_eyebrows(app, roi1);
            
            app.NewCenter1 = app.NewCenter;
            app.NewRad1 = app.NewRad;

            % Main processing loop
            while hasFrame(app.Video) && app.IsRunning
                videoframeg = read(app.Video, app.CountFrame);
                app.CountFrame = app.CountFrame + 10;
                
                % Detect face in current frame
                bboxes = faceDetector(videoframeg);
                if isempty(bboxes)
                    continue;
                end
                bbox = bboxes(1, :);
                
                % Extract eye region
                eyeRegionY = bbox(2) + round(bbox(4) * 0.15);
                eyeRegionHeight = round(bbox(4) * 0.35);
                roi1 = imcrop(videoframeg, [bbox(1), eyeRegionY, bbox(3), eyeRegionHeight]);

                % Detect eyes and eyebrows in current frame
                [app.NewCenter, app.NewRad, app.CountBlink, roi1] = find_eyes(app.Merhak, roi1, app.CountBlink, 5);
                app.EyebrowCenter = find_eyebrows(app, roi1);

                % Display results
                imshow(roi1, 'Parent', app.AxesDisplay);
                hold(app.AxesDisplay, 'on');
                
                if max(app.NewCenter) > 0
                    viscircles(app.AxesDisplay, app.NewCenter, app.NewRad*0.1, 'EdgeColor', 'r');
                    plot(app.AxesDisplay, app.EyebrowCenter(1), app.EyebrowCenter(2), 'bx', 'MarkerSize', 10, 'LineWidth', 2);
                end
                hold(app.AxesDisplay, 'off');
                
                plotxy(app.NewCenter1, app.NewCenter, app.CountFrame);
            
                if app.CountFrame >= app.Video.NumFrames
                    app.IsRunning = false;
                end
                pause(1 / app.Video.FrameRate);
            end
            
            app.StatusLabel.Text = 'Processing Complete';
        end

        function StopButtonPushed(app, event)
            app.IsRunning = false;
            app.StatusLabel.Text = 'Stopped';
        end

        function [middleEyebrows] = find_eyebrows(~, faceROI)
            % Convert face ROI to grayscale and apply Gaussian filter
            grayFace = rgb2gray(faceROI);
            filteredFace = imgaussfilt(grayFace, 2);
            
            % Edge detection and Hough transform for line detection
            edges = edge(filteredFace, 'Canny');
            [H, T, R] = hough(edges);
            peaks = houghpeaks(H, 10);
            lines = houghlines(edges, T, R, peaks, 'FillGap', 10, 'MinLength', 30);

            leftLines = [];
            rightLines = [];
            
            for i = 1:length(lines)
                xy = [lines(i).point1; lines(i).point2];
                if mean(xy(:,1)) < size(faceROI, 2) / 2
                    leftLines = [leftLines; mean(xy, 1)];
                else
                    rightLines = [rightLines; mean(xy, 1)];
                end
            end
            
            if ~isempty(leftLines) && ~isempty(rightLines)
                leftEyebrowCenter = mean(leftLines, 1);
                rightEyebrowCenter = mean(rightLines, 1);
                middleEyebrows = mean([leftEyebrowCenter; rightEyebrowCenter], 1);
            else
                middleEyebrows = [0, 0];
            end
        end
    end

    methods (Access = private)
        function createComponents(app)
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 800 600];
            app.UIFigure.Name = 'Pupil Tracking App';

            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.Position = [50 50 100 30];
            app.StartButton.Text = 'Start';
            app.StartButton.ButtonPushedFcn = @(btn, event) app.StartButtonPushed(event);

            app.StopButton = uibutton(app.UIFigure, 'push');
            app.StopButton.Position = [200 50 100 30];
            app.StopButton.Text = 'Stop';
            app.StopButton.ButtonPushedFcn = @(btn, event) app.StopButtonPushed(event);

            app.AxesDisplay = uiaxes(app.UIFigure);
            app.AxesDisplay.Position = [50 100 700 500];
            title(app.AxesDisplay, 'Video Display');

            app.StatusLabel = uilabel(app.UIFigure);
            app.StatusLabel.Position = [350 50 300 30];
            app.StatusLabel.Text = 'Status: Ready';

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)
        function app = PupilTrackingApp
            app.createComponents();
        end
    end
end