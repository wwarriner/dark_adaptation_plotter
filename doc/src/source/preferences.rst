Preferences
===========

The preferences dialog contains customization options that affect the entire plot. These options will be reflected in the plot as you change them, but will only be saved once you click "Accept". Clicking "Cancel" will revert any changes made since opening the dialog. Closing the dialog without clicking any buttons has the same effect as "Cancel". Clicking "Reset to Default" will revert all preferences to their default values. This can be undone by clicking "Cancel" or closing the dialog without clicking "Accept".

.. figure:: /img/preferences.png
   :alt: The preferences dialog.

Arrow Appearance
----------------

1. Arrow head size (pt) - Changes the height and width of the arrowhead in points. *Default: 12*
2. Arrow line width (pt) - Changes the width of the arrow line in points. *Default: 2.0*

Marker Appearance
-----------------

3. Marker edge color - Allows selecting the edge color of all markers. *Default: Black*

   a. Same - same as the marker color selected in the table. Effectively, this means no marker edge color.
   b. Black - solid black marker edge.
   c. Invert - The closest CIELAB inverse color in the sRGB space. This should always produce high hue contrast, but may not give very good lightness and saturation contrast.

Legend
------

4. Legend location - The location of the legend based on MATLAB built-in options. Not all options are available for aesthetic and practical reasons. *Default: North*

   a. North, NorthEast - inside the axes, near the top
   b. South, SouthEast - inside the axes, near the bottom
   c. East - inside the axes to the right
   d. NorthOutside, SouthOutside, EastOutside - outside the axes, as above
   e. Best - inside the axes, minimizes overlap of legend and plot data
   f. BestOutside - outside the axes, top-right corner

Axes
----

5. X axis - Time since start of experiment

   a. title - Title or label of X axis. Default is research publication standard. *Default: Minutes following photobleach*
   b. maximum - Maximum value in minutes. *Default: 20.00*
   c. major tick - enumerated ticks. *Default: 5.00*
   d. minor tick - non-enumerated ticks, set equal to major tick to hide. *Default: 1.00*

6. Y axis - Sensitivity to light

   a. title - Title or label of Y axis. *Default: Log Sensitivity*
   b. minimum - Minimum value in dB. *Default: 0.00*
   c. maximum - Maximum value in dB. *Default: 5.00*
   d. major tick - enumerated ticks. *Default: 1.00*
   e. minor tick - enumerated ticks. *Default: 0.50*

Export
------

7. Desired export size (px) - Size of exported rasterized :code:`png` file in pixels. This value affects the relative size of objects in vector :code:`pdf` and :code:`eps` files as well. Use a consistent value if you need multiple plots in the same publication. *Default: 500*.
8. Default export extension - Which extension should be the default choice when exporting. *Default: .png*