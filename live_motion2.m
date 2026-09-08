function live_motion_demo_FINAL
% LIVE_MOTION_DEMO_FINAL
% Clean, smooth MATLAB UI for Wi-Fi CSI human-motion simulation.
%
% Modes:
%   SIT STILL -> low CSI variation
%   WALKING   -> periodic CSI variation
%   FALLING   -> short transient followed by recovery
%
% The display demonstrates:
%   Motion -> CSI -> DSP filtering -> FFT -> classification
%
% This is a MATLAB SOFTWARE SIMULATION. ESP32 hardware is separate.

clc;
close all;

%% SETTINGS
Fs = 100;
N = 400;                       % 4-second moving window
t = (0:N-1)/Fs;
f = (0:floor(N/2))/N*Fs;

rng(12);
[b,a] = butter(4,5/(Fs/2),'low');

mode = "AUTO";
t0 = tic;
lastFrame = tic;

%% COLORS
bg = [0.055 0.065 0.085];
panel = [0.09 0.105 0.13];
txt = [0.92 0.94 0.97];
muted = [0.60 0.65 0.72];
accent = [0.20 0.65 1.00];

%% MAIN WINDOW
fig = figure( ...
    'Name','Wi-Fi CSI Human Motion Sensing', ...
    'NumberTitle','off', ...
    'Color',bg, ...
    'MenuBar','none', ...
    'ToolBar','none', ...
    'Resize','on', ...
    'Position',[80 60 1450 820]);

set(fig,'CloseRequestFcn',@closeDemo);

%% HEADER
uicontrol(fig,'Style','text', ...
    'String','WI-FI CSI HUMAN MOTION SENSING', ...
    'Units','normalized', ...
    'Position',[0.03 0.935 0.94 0.045], ...
    'BackgroundColor',bg, ...
    'ForegroundColor',txt, ...
    'FontSize',20, ...
    'FontWeight','bold', ...
    'HorizontalAlignment','left');

uicontrol(fig,'Style','text', ...
    'String','Real-time DSP simulation  •  CSI → Filtering → FFT → Classification', ...
    'Units','normalized', ...
    'Position',[0.03 0.905 0.94 0.028], ...
    'BackgroundColor',bg, ...
    'ForegroundColor',muted, ...
    'FontSize',10, ...
    'HorizontalAlignment','left');

%% PERSON PANEL
axP = axes(fig,'Position',[0.035 0.51 0.28 0.35], ...
    'Color',panel,'XColor',panel,'YColor',panel);
axis(axP,[0 10 0 12]);
axis(axP,'off');
title(axP,'HUMAN MOTION','Color',txt,'FontSize',13);

% TX / RX
text(axP,0.7,10.8,'TX','Color',accent,'FontSize',11,'FontWeight','bold');
text(axP,8.6,10.8,'RX','Color',accent,'FontSize',11,'FontWeight','bold');
plot(axP,1,10,'s','MarkerSize',13,'LineWidth',2,'Color',accent);
plot(axP,9,10,'s','MarkerSize',13,'LineWidth',2,'Color',accent);

% CSI wave arcs
th = linspace(-0.7,0.7,50);
for r = [0.5 0.8 1.1]
    plot(axP,1+r*cos(th),10+r*sin(th),'Color',accent,'LineWidth',0.8);
end

% Person
head = rectangle(axP,'Position',[4.55 8 0.9 0.9], ...
    'Curvature',[1 1],'EdgeColor',txt,'LineWidth',2);
body = line(axP,[5 5],[8 5.7],'Color',txt,'LineWidth',4);
armL = line(axP,[5 4],[7.3 6.2],'Color',txt,'LineWidth',3);
armR = line(axP,[5 6],[7.3 6.2],'Color',txt,'LineWidth',3);
legL = line(axP,[5 4],[5.7 2.4],'Color',txt,'LineWidth',3);
legR = line(axP,[5 6],[5.7 2.4],'Color',txt,'LineWidth',3);

motionLabel = text(axP,5,0.75,'SIT STILL', ...
    'Color',txt,'FontSize',18,'FontWeight','bold', ...
    'HorizontalAlignment','center');

%% CSI PANEL
axC = axes(fig,'Position',[0.355 0.54 0.61 0.32], ...
    'Color',panel,'XColor',muted,'YColor',muted);
hold(axC,'on'); grid(axC,'on');
axC.GridAlpha = 0.12;
xlabel(axC,'Time (s)','Color',muted);
ylabel(axC,'CSI amplitude','Color',muted);
title(axC,'LIVE CSI SIGNAL','Color',txt,'FontSize',13);
xlim(axC,[0 4]);

rawLine = plot(axC,t,nan(size(t)), ...
    'Color',[0.25 0.55 0.95],'LineWidth',0.8);
filtLine = plot(axC,t,nan(size(t)), ...
    'Color',[1.00 0.45 0.10],'LineWidth',2.0);

legend(axC,{'Raw CSI','DSP filtered'}, ...
    'TextColor',txt,'Color',panel,'EdgeColor',muted, ...
    'Location','northwest');

%% FFT PANEL
axF = axes(fig,'Position',[0.355 0.12 0.30 0.30], ...
    'Color',panel,'XColor',muted,'YColor',muted);
hold(axF,'on'); grid(axF,'on');
axF.GridAlpha = 0.12;
xlabel(axF,'Frequency (Hz)','Color',muted);
ylabel(axF,'Magnitude','Color',muted);
title(axF,'DSP • FFT','Color',txt,'FontSize',13);
xlim(axF,[0 6]);

fftLine = plot(axF,f,nan(size(f)), ...
    'Color',accent,'LineWidth',1.8);

%% STATUS PANEL
axS = axes(fig,'Position',[0.70 0.12 0.265 0.30], ...
    'Color',panel,'XColor',panel,'YColor',panel);
axis(axS,[0 1 0 1]);
axis(axS,'off');

text(axS,0.06,0.87,'SYSTEM STATUS','Color',txt, ...
    'FontSize',14,'FontWeight','bold');

text(axS,0.06,0.68,'INPUT','Color',muted,'FontSize',9,'FontWeight','bold');
text(axS,0.06,0.60,'Wi-Fi CSI','Color',txt,'FontSize',12);

text(axS,0.06,0.45,'DSP','Color',muted,'FontSize',9,'FontWeight','bold');
text(axS,0.06,0.37,'Butterworth Low-Pass + FFT','Color',txt,'FontSize',12);

text(axS,0.06,0.22,'CLASSIFICATION','Color',muted,'FontSize',9,'FontWeight','bold');
classText = text(axS,0.06,0.08,'SIT STILL','Color',txt, ...
    'FontSize',20,'FontWeight','bold');

freqText = text(axS,0.57,0.08,'0.00 Hz','Color',muted, ...
    'FontSize',10,'HorizontalAlignment','right');

%% CONTROL BAR
uicontrol(fig,'Style','pushbutton','String','SIT STILL', ...
    'Units','normalized','Position',[0.035 0.025 0.13 0.055], ...
    'FontSize',10,'FontWeight','bold', ...
    'Callback',@(~,~)chooseMode("SIT STILL"));

uicontrol(fig,'Style','pushbutton','String','WALKING', ...
    'Units','normalized','Position',[0.175 0.025 0.13 0.055], ...
    'FontSize',10,'FontWeight','bold', ...
    'Callback',@(~,~)chooseMode("WALKING"));

uicontrol(fig,'Style','pushbutton','String','FALLING', ...
    'Units','normalized','Position',[0.315 0.025 0.13 0.055], ...
    'FontSize',10,'FontWeight','bold', ...
    'Callback',@(~,~)chooseMode("FALLING"));

uicontrol(fig,'Style','pushbutton','String','▶  AUTO DEMO', ...
    'Units','normalized','Position',[0.455 0.025 0.17 0.055], ...
    'FontSize',10,'FontWeight','bold', ...
    'Callback',@(~,~)chooseMode("AUTO"));

uicontrol(fig,'Style','pushbutton','String','■  STOP', ...
    'Units','normalized','Position',[0.635 0.025 0.13 0.055], ...
    'FontSize',10,'FontWeight','bold', ...
    'Callback',@(~,~)chooseMode("STOP"));

uicontrol(fig,'Style','text', ...
    'String','Simulation only • ESP32 pipeline remains separate', ...
    'Units','normalized','Position',[0.78 0.025 0.19 0.055], ...
    'BackgroundColor',bg,'ForegroundColor',muted, ...
    'FontSize',9,'HorizontalAlignment','right');

%% TIMER: smoother than a while-loop
tmr = timer( ...
    'ExecutionMode','fixedSpacing', ...
    'Period',0.06, ...            % ~16 FPS, much lighter on MATLAB
    'BusyMode','drop', ...
    'TimerFcn',@updateDemo);

start(tmr);

%% ================= CALLBACKS =================

    function chooseMode(newMode)
        mode = newMode;
        t0 = tic;
    end

    function updateDemo(~,~)
        if ~isvalid(fig)
            return;
        end

        % Do not render faster than necessary.
        if toc(lastFrame) < 0.055
            return;
        end
        lastFrame = tic;

        elapsed = toc(t0);

        if mode == "AUTO"
            q = mod(elapsed,18);
            if q < 6
                act = "SIT STILL";
            elseif q < 12
                act = "WALKING";
            else
                act = "FALLING";
            end
        elseif mode == "STOP"
            act = "SIT STILL";
        else
            act = mode;
        end

        % Generate signal
        raw = makeCSI(act,t,elapsed);

        % DSP
        filtered = filtfilt(b,a,raw);

        % FFT
        x = filtered - mean(filtered);
        Y = abs(fft(x));
        P1 = Y(1:floor(N/2)+1)/N;
        P1(2:end-1) = 2*P1(2:end-1);

        valid = (f >= 0.15 & f <= 6);
        fv = f(valid);
        pv = P1(valid);

        [peakVal,idx] = max(pv);
        domFreq = fv(idx);

        % Plot updates only
        rawLine.YData = raw;
        filtLine.YData = filtered;

        ymin = min(raw)-0.7;
        ymax = max(raw)+0.7;
        if ymax-ymin < 2
            mid = mean(raw);
            ymin = mid-1;
            ymax = mid+1;
        end
        ylim(axC,[ymin ymax]);

        fftLine.YData = P1;
        ylim(axF,[0 max(0.3,peakVal*1.25)]);

        % Motion graphics
        animatePerson(act,elapsed);

        % Status
        motionLabel.String = act;
        classText.String = act;
        freqText.String = sprintf('%.2f Hz',domFreq);

        drawnow limitrate nocallbacks;
    end

    function y = makeCSI(act,tt,tm)
        base = 24.5 + 0.12*sin(2*pi*0.22*tt);

        switch act
            case "SIT STILL"
                y = base ...
                    + 0.16*sin(2*pi*0.35*tt + tm) ...
                    + 0.10*sin(2*pi*0.12*tt) ...
                    + 0.12*randn(size(tt));

            case "WALKING"
                y = base ...
                    + 1.05*sin(2*pi*1.45*tt + tm*1.3) ...
                    + 0.32*sin(2*pi*2.9*tt + tm) ...
                    + 0.18*randn(size(tt));

            case "FALLING"
                y = base + 0.13*sin(2*pi*0.25*tt) ...
                    + 0.11*randn(size(tt));

                % Moving fall event for repeated AUTO cycles
                eventTime = 2.7 + 0.25*sin(tm*0.5);
                impact = 3.8*exp(-((tt-eventTime)/0.075).^2);
                recovery = 1.0*exp(-((tt-eventTime)/0.38).^2) ...
                    .*sin(2*pi*2.8*(tt-eventTime));
                y = y + impact + recovery;

            otherwise
                y = base + 0.1*randn(size(tt));
        end
    end

    function animatePerson(act,tm)
        switch act
            case "SIT STILL"
                head.Position = [4.55 7.8 0.9 0.9];
                body.XData = [5 5.5]; body.YData = [7.8 5.8];
                armL.XData = [5.1 4.0]; armL.YData = [7.2 6.6];
                armR.XData = [5.1 6.2]; armR.YData = [7.2 6.6];
                legL.XData = [5.5 4.1]; legL.YData = [5.8 4.7];
                legR.XData = [5.5 6.8]; legR.YData = [5.8 4.7];

            case "WALKING"
                p = tm*6.5;
                head.Position = [4.55 8 0.9 0.9];
                body.XData = [5 5]; body.YData = [8 5.7];
                armL.XData = [5 4+0.5*sin(p)];
                armL.YData = [7.3 6.1];
                armR.XData = [5 6-0.5*sin(p)];
                armR.YData = [7.3 6.1];
                legL.XData = [5 4+0.85*sin(p)];
                legL.YData = [5.7 2.4];
                legR.XData = [5 6-0.85*sin(p)];
                legR.YData = [5.7 2.4];

            case "FALLING"
                head.Position = [6.8 4.0 0.9 0.9];
                body.XData = [6.8 4.7]; body.YData = [4.4 4.0];
                armL.XData = [5.9 4.7]; armL.YData = [4.2 3.1];
                armR.XData = [5.9 4.9]; armR.YData = [4.3 5.2];
                legL.XData = [4.7 3.5]; legL.YData = [4.0 3.0];
                legR.XData = [4.7 3.8]; legR.YData = [4.0 4.8];
        end
    end

    function closeDemo(~,~)
        try
            if exist('tmr','var') && isvalid(tmr)
                stop(tmr);
                delete(tmr);
            end
        catch
        end
        delete(fig);
    end
end
