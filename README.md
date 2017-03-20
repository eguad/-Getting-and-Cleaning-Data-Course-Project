# -Getting-and-Cleaning-Data-Course-Project
Getting and Cleaning Data Course Project
========================================


run_analysis.R
--------------

This script produces a summary of all mean and std.  deviation columns in the Samsung
Human Activity Recognition dataset created at UCI using Samsung smart phones attached to
30 test subjects.

The column names are read from the 'features' file, and the names beautified by
lower-casing all letters and stripping all punctuation characters.

Using these column names, data frames are created for each dataset, 'test' and 'train'.
Their corresponding subejct and activity files are also read and attached to their
respective data frames.  The two data frames are row bound into a third data frame upon
which all further processing occurs.

Any column not containing the strings 'mean' or 'std' are removed from the data frame; 
the 'activity' and 'subject' columns are also kept.

The integers of the activity column are replaced using labels from the 'activity_labels'
file, and the resulting data frame is grouped by activity and subject.

Finally, all non-grouping columns are averaged and returned in the tidy dataset.
