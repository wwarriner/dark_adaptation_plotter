Quickstart Guide
================

The Dark Adaptation Plotter is a tool for creating publication-quality plots of dark adaptation data. It has a number of features for selecting data and changing the appearance of the plot. You can preview your plot before generating it, and output formats include :code:`png`, :code:`pdf` and :code:`eps`.

Dark Adaptation Plots
---------------------

The purpose of Dark Adaptation Plots is to compare the dark adaptation recovery of patients with different markers or features of disease, especially Age-related Macular Degeneration (AMD).

.. figure:: /img/dark_adaptation_plots_001.png
   :width: 400
   :alt: An example dark adaptation plot. Data for two patients/subjects labeled 1 and 2 are shown. The data for 1 trends down and right very slowly. The data for 2 trends down quickly and has an arrow pointing at a little over 5 minutes on the X axis.

Above is a prototypical Dark Adaptation Plot. The plot is a scatter plot with arrows. The horizontal or X axis is time since the start of the experiment, and the vertical or Y axis is log sensitivity. Note that the vertical axis is flipped so that sensitivity to light increases downward. The flip is done because higher sensitivity means less light is needed to see the same target.

Each patient or subject has one set of data which generally has increasing sensitivity with increasing time so the scatter plots follow a down-right trend. Different patients will trend downward at different rates, and some may not trend downward at all in the visible space of the plot. An arrow is drawn at the location of the Rod Intercept Time (RIT) pointing to the estimated time of dark adaptation recovery. The arrow is only drawn if the RIT is within the visible X axis. The RIT will need to be supplied in the input data.

Typical Workflow
----------------

1. Start the application. The main window will be shown.

   .. figure:: /img/workflow_002.png
      :alt: Main window of the Dark Adaptation Plotter. A menu bar is visible at the top with File, Edit and Help menus. The window is split into two panels. The left panel is a table containing no data. The headers are ID, an Eye emoji, Color, Marker and Size. The right panel has an empty graph with X axis labeled Minutes following photobleach and Y axis labeled Log Sensitivity.

2. Load your data by clicking "File" and then "Open Data..." in the menu bar. Data should be in CSV format and the following fields must be available.

   a. Patient ID
   b. Rod Intercept Time (minutes)
   c. Log Sensitivity (dB)
   d. Minutes Since Photobleach

   The columns can have any name and will be selected in the next step.

   .. figure:: /img/workflow_003.png
      :alt: File menu contents including Open Data..., Clear Data, Export Preview..., Export As..., and Exit.

3. Select which columns in your file contain which fields by double-clicking in the second column of the left hand panel, labeled "Double click to select below". When you are done, click "Done".

   .. figure:: /img/workflow_004.png
      :alt: Column Selection window showing columns being matched with application required fields.

4. After a moment, the table on the left hand side of the main window will fill out.

   .. figure:: /img/workflow_005.png
      :alt: Main window with table now populated by values.

6. Interact with the elements of the table to customize your data selection and appearance.

   a. Scroll up and down in the table if there is more data than can be shown in one page.
   b. Click the checkboxes in the cells in the "eye" column to select which data rows should be visible.
   c. Double-click on a colored cell in the "color" column to open a color picker for that data row. There is a known-issue that once a box is selected and the color picker is opened and closed, the picker can't be reopened while that cell is selected. Select another cell and then try again.
   d. Double-click on a cell in the "marker" column to select a different marker for that data row.
   e. Click on a cell in the "size" column to change the marker size for that data row.

   .. figure:: /img/workflow_006.png
      :alt: Main window with data from three patients/subjects visible, some modifications have been made to marker and size of one patient.

7. Further customization can be performed using tools in the "Edit" menu in the menu bar.

   a. Clicking "Font..." in the "Edit" menu will open a font selection dialog, where you can change font, typeface and size.
   b. Clicking "Preferences..." will open a dialog with additional options.

   .. figure:: /img/workflow_007.png
      :alt: Edit menu showing Font and Preferences options.

8. Once the plot has been customized, click "File" and then "Export Preview..." to open a new window with a preview of the plot as it will be saved. The "Export As..." menu selection in the preview window will allow exporting as in the next step. It is recommended to preview at least one plot to ensure it looks as desired before making additional plots.

   .. figure:: /img/workflow_008.png
      :alt: Export Preview window showing graph as it will be written to disk. Export As... menu option is visible in the top menu.

9.  Click "File" and then "Export As..." to open a save file dialog and export without previewing.
