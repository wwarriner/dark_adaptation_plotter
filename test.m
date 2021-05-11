%% DATA CLASS
DATA_FILE = "D:/repos/dark_adaptation_plotter/test_data.csv";
data = dapData();
data.load(DATA_FILE);

%% PLOT
% FIGURE
fh = uifigure();
fh.Color = [1.0 1.0 1.0]; % MAKE CLASS

% AXES
axh = axes(fh);
hold(axh, "on");
axh.TickDir = "out";


% X AXIS
X_LABEL_DEFAULT = "Minutes following photobleach"; % CONFIG
X_MIN_DEFAULT = 0; % CONFIG
X_STEP_DEFAULT = 5; % CONFIG
X_MINOR_STEP_DEFAULT = 1; % CONFIG
X_MAX_DEFAULT = 25; % CONFIG

x_label = X_LABEL_DEFAULT; % USER SELECTED
x_min = floor_to_nearest(X_MIN_DEFAULT, X_STEP_DEFAULT); % USER SELECTED
x_max = ceil_to_nearest(X_MAX_DEFAULT, X_STEP_DEFAULT); % USER SELECTED
x_step = X_STEP_DEFAULT; % USER SELECTED
x_minor_step = X_MINOR_STEP_DEFAULT; % USER SELECTED

axh.XLabel.String = x_label;
axh.XLim = [x_min x_max];
axh.XTick = x_min : x_step : x_max;
axh.XAxis.MinorTick = "on";
axh.XAxis.MinorTickValues = x_min : x_minor_step : x_max;

% Y AXIS
Y_LABEL_DEFAULT = "Log Sensitivity"; % CONFIG
Y_MIN_DEFAULT = 0; % CONFIG
Y_STEP_DEFAULT = 0.5; % CONFIG
Y_MINOR_STEP_DEFAULT = 0.1; % CONFIG
Y_MAX_DEFAULT = 4.5; % CONFIG

y_label = Y_LABEL_DEFAULT; % USER SELECTED
y_min = floor_to_nearest(Y_MIN_DEFAULT, Y_STEP_DEFAULT); % USER SELECTED
y_max = ceil_to_nearest(Y_MAX_DEFAULT, Y_STEP_DEFAULT); % USER SELECTED
y_step = Y_STEP_DEFAULT; % USER SELECTED
y_minor_step = Y_MINOR_STEP_DEFAULT; % USER SELECTED

axh.YLabel.String = y_label;
axh.YLim = [y_min y_max];
axh.YTick = y_min : y_step : y_max;
axh.YAxis.MinorTick = "on";
axh.YAxis.MinorTickValues = y_min : y_minor_step : y_max;
axh.YAxis.Direction = "reverse";

% RECOVERY SENSITIVITY HLINE PLOT
RECOVERY_LOG_SENSITIVITY = 3.0; % CONFIG
recovery_log_sensitivity = RECOVERY_LOG_SENSITIVITY; % USER SELECTED
ph = hline(axh, recovery_log_sensitivity); % CAN BE UPDATED
ph.LineStyle = ":";
ph.LineWidth = 2.0;
ph.Color = [0.0 0.0 0.0];

%% DATA PLOT

COUNT = 3;

ids = data.ids;
ppt_id = randsample(ids, COUNT);
markers = ["d" "s" "o"];
colors = {Color.RED(); Color.GREEN(); Color.BLUE()};

for i = 1 : COUNT
    patient = data.get(ppt_id(i));
    
    MARKER = markers{i}; % CONFIG, WILL NEED A TABLE OF DEFAULTS AND TABLE OF USER SELECTED VALUES
    MARKER_SIZE = 8; % CONFIG
    COLOR = colors{i}; % CONFIG (use uisetcolor())
    ARROW_LINE_WIDTH = 2; % CONFIG

    dplot = dapPlot(patient);
    dplot.marker = MARKER;
    dplot.marker_size = MARKER_SIZE;
    dplot.color = COLOR;
    dplot.arrow_line_width = ARROW_LINE_WIDTH;
    dplot.draw(axh); 
end
