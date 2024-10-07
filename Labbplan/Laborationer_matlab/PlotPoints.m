% Written by Lucas Strömberg and Johannes Langelaar
% Lucstromberg@gmail.com, JohannesLangelaar@hotmail.com

function PlotPoints(s,t,u,pos,vel,ref,refVel)
%PLOTSIMULATION Plots real-time data.
%   If run with only s and t as parameter; creates a UI figure window with
%graph, wheel and checkbox objects.
%   If run with all parameters; plots point in GUI

persistent fig graph graph2 wheelLine wheelRef zeroRef uLine posLine refLine velLine refVelLine cbx_u cbx_pos cbx_ref cbx_vel cbx_ref_vel

% Initiate graphics
if nargin < 3    
    % Figure window
    fig = uifigure('Name','ControlGUI', 'Position',[100 100 1000 500], 'Color', 'w','Resize','off','DeleteFcn',@(fig,event) CloseFigure(fig,fig));
        
    % Graph for plotting
    graph = uiaxes(fig, 'Position', [10 200 700 300]);
    graph.BackgroundColor = 'w';
    
    % Graph for wheel animation
    graph2 = uiaxes(fig, 'Position', [600 100 300 300]);
    graph2.BackgroundColor = 'w';
    graph2.XAxis.Color = 'w';
    graph2.YAxis.Color = 'w';
    circle = rectangle(graph2, 'Position', [0 0 2 2],'Curvature',[1 1], 'LineWidth', 1.5, 'FaceColor','y');
    axis(graph2,[-0.2 2.5 -0.2 2.5]);
    
    % Start button
    start_btn = uibutton(fig,'Text','Start','FontSize',20,'Position',[250 80 160 80],'ButtonPushedFcn',@(start_btn,event) StartButton(start_btn,fig));
    
    % Animated line objects
    wheelLine = animatedline(graph2,'Color','r','LineWidth',2);
    addpoints(wheelLine,[1 1+sin(0)],[1 1+cos(0)]);
    wheelRef = animatedline(graph2,'color','b','LineWidth',3);
    zeroRef = animatedline(graph2,'color','k','LineWidth',3);
    addpoints(zeroRef,[1+1.05*sin(0) 1+1.2*sin(0)],[1+1.05*cos(0) 1+1.2*cos(0)]);
    
    % Create animatedline objects
    uLine = animatedline(graph,'Color','g','LineWidth',1.4,'Visible',0);
    posLine = animatedline(graph,'Color','r','LineWidth',1.4,'Visible',0);
    refLine = animatedline(graph,'Color','b','LineWidth',1.4,'Visible',0);
    velLine = animatedline(graph,'Color','c','LineWidth',1.4,'Visible',0);
    refVelLine = animatedline(graph,'Color','m','LineWidth',1.4,'Visible',0);
    
    % Check boxes
    cbx_u = uicheckbox(fig, 'Text','Control Signal','Value', 0,'Position', [50 150 200 20],'ValueChangedFcn',@(cbx_u,event) CheckBoxToggled(cbx_u,fig,uLine));
    cbx_pos = uicheckbox(fig, 'Text','Angular Position','Value', 0,'Position', [50 130 200 20],'ValueChangedFcn',@(cbx_pos,event) CheckBoxToggled(cbx_pos,fig,posLine));
    cbx_ref = uicheckbox(fig, 'Text','Reference Angular Position','Value', 0,'Position', [50 110 200 20],'ValueChangedFcn',@(cbx_ref,event) CheckBoxToggled(cbx_ref,fig,refLine));
    cbx_vel = uicheckbox(fig, 'Text','Angular Velocity','Value', 0,'Position', [50 90 200 20],'ValueChangedFcn',@(cbx_vel,event) CheckBoxToggled(cbx_vel,fig,velLine));
    cbx_ref_vel = uicheckbox(fig, 'Text','Reference Angular Velocity','Value', 0,'Position', [50 70 200 20],'ValueChangedFcn',@(cbx_ref_vel,event) CheckBoxToggled(cbx_ref_vel,fig,refVelLine));
    
    % Set axis and legend and draw the uifigure
    [~,deltat]=DCservo(); % Sampling time
    axis(graph,[0 length(t)*deltat -pi 4]);
    xlabel(graph,'Time [s]');
    legend(graph,'Control Signal [V]','Angular Position [rad]','Reference Angular Position [rad]','Angular Velocity [rad/s]','Reference Angular Velocity [rad/s]','SelectionHighlight','off','Location','bestoutside');
    
    % Wait for Start Button to be pressed
    drawnow;
    uiwait(fig);
    
else % Plot a point
        
    % For plotting purposes, map the position vectors to [-pi,pi]
    pos = mod(pos,2*pi);
    indices = find(pos > pi);
    pos(indices) = pos(indices) - 2*pi;
    
    % Update wheel
    clearpoints(wheelLine);
    addpoints(wheelLine,[1 1+sin(pos)],[1 1+cos(pos)]);
    
    % Wheel reference point
    if ~isnan(ref)
        clearpoints(wheelRef);
        addpoints(wheelRef,[1+1.05*sin(ref) 1+1.2*sin(ref)],[1+1.05*cos(ref) 1+1.2*cos(ref)]);
        % If we succeed, it means that we have a reference point and that
        % the zero point should disappear.
        clearpoints(zeroRef);
    end
    
    % try/catch-blocks is included since some data will sometimes be
    % nan
    try
        addpoints(uLine,t,u);
    catch
    end
    try
        addpoints(posLine,t,pos);
    catch
    end
    try
        addpoints(refLine,t,ref);
    catch
    end
    try
        addpoints(velLine,t,vel);
    catch
    end
    try
        addpoints(refVelLine,t,refVel);
    catch
    end
    
    drawnow;
    
end


    % Callback function for the checkboxes
    function CheckBoxToggled(ObjectH, EventData, line)
        line.Visible = ObjectH.Value;
    end

    % Callback function for the start button
    function StartButton(ObjectH, EventData)
        uiresume(fig);
    end

    % Callback function for when closing the GUI
    function CloseFigure(ObjectH, EventData)
        AnalogWrite(s,0);
        delete(timerfind);
    end
end