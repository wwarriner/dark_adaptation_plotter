feature plan:

1. uniform marker size setting
   1. One option is to create a separate menu item and dialog with warnings about destructiveness.
      1. The dialog would let you set the marker size, when click cancel or X nothing changes. When click accept (destructive!) every entry in marker size col is set to the new value. Also sets the default value for future instances.
   2. Another option is to put it in the prefs menu. This requires creating a facility in prefs for on-open and on-cancel event callbacks. Then the PlotTable needs to save its state on-open and reload it on-cancel. The StyleManager would need robust save/load facilities as well. The trick is that the UI table is tied into the style manager. So when we reload the state, we'd need to create a new style manager, and then add all the styles from the old one to the new one.

2. Add column for class/group
   1. This requires adding a column in the plottable (easy)
   2. Also requires modifying the metaname chooser to allow optional columns.
      1. What do we do downstream if the optional column ISNT provided or selected?
         1. We could set the optional column weight to zero so it doesn't show up, and fill it with empty string.
      2. Should we warn the user if they are skipping optional columns with a modal popup?
         1. Accept -> "I have selected the columns I need"
         2. Cancel -> "Go back"
      3. How do we present required vs optional choices to the user in the interface?
         1. Possibly two separate clusters in the table
         2. or a non-editable column that says "Required" vs "Optional"
   3. Do we allow users to "oopsie" the column back? Or make them reload the file again? These are probably the same thing on the backend anyway...
