%% DATA CLASS
DATA_FILE = "D:/repos/dark_adaptation_plotter/test_data.csv";
data = dapData();
data.load(DATA_FILE);

%% PLOT
fh = uifigure();
fh.Color = [1.0 1.0 1.0]; % MAKE CLASS

ax = dapAxes(fh);

recovery_line = dapRecoveryLine();
ax.draw_on(@recovery_line.draw);

%% DATA PLOT

COUNT = 3;

ids = data.ids;
ppt_id = randsample(ids, COUNT);
markers = ["d" "s" "o"];
colors = {Color.RED(); Color.GREEN(); Color.BLUE()};

dplts = dapPlots();

for i = 1 : COUNT
    patient = data.get(ppt_id(i));
    dplot = dapPlot(patient);
    dplts.add(ppt_id(i), dplot);
    ax.draw_on(@dplot.draw);
end

dplts.update_visible(ppt_id(2), true);
dplts.update_color(ppt_id(2), Color.RED());
dplts.update_visible(ppt_id(1), true);
dplts.update_marker(ppt_id(1), "o");
