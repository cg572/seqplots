Versions history
================

CHANGES IN VERSION 1.4.1
--------------------------------------------------------------------------------

PACKAGE:

* RJSONIO replaced with jsonlite package for encoding/decoding JSON
* Sub-heatmaps accepts multilevel color palettes in plotHeatmap function
* Better dendrogram positioning for heatmaps with hclust and single sub-heatmap

GUI:

* "Load saved plot set" select input replaced with searchable selectize input
* Tracks and feature names are shown without extensions
* Plot Preview GUI elements are shown directly after calculation finishes or 
  save dataset si loaded, even if no pair is selected. 
* Download buttons moved to bottom of side panel 
* Color palettes from RColorBrewer package can be selected in GUI
* Web interface tab for managing the reference genomes

BUGFIX:

* Plot Preview shows up when needed with shiny 0.12.0 (issue #6)
* Heatmap top labels and color key font sizing works properly
* Clustering report download works when source feature file were deleted


CHANGES IN VERSION 1.3.0
--------------------------------------------------------------------------------

* New package version for Bioconductor 3.1 release


CHANGES IN VERSION 1.2.0
--------------------------------------------------------------------------------

PACKAGE:

* plot a dendrogram as first panel on heatmap plot clustered with hierarchical 
  clustering
* heatmap can be plotted as vector graphics (default for R scripting) or 
  raster graphics (default for web GUI)
* heatmaps can be sorted in increasing or decreasing order
* y-axis is annotated with cluster IDs and number of data rows (heatmap)
* x-axis is annotated with base pairs, e.g. 10bp, 1kb, 1.2Mb, etc.
* heatmaps can be plotted using GGplot2 package instead of R base graphics 
  system
* speed-up in motif plots thanks to faster, vectored implementation 
  of motif density data acquisition 
* code simplification - seqplots in Shiny GUI mode use all functions 
  from package core

GUI:

* feature-track pairs selection grid have UI elements to multi-select and batch 
  change labels/colors/etc.
* option to make a clustering repeatable (works by reusing a .Random.seed)
* option to plot selected cluster only as heatmap
* SeqPlots GUI updated to work with Bootstrap v3.3.1

BUGFIX:

* lines separating the clusters are drawn in correct places on 
  grDevices::quartz devices
* proper positioning of 3' ends of anchored region in motif plot
* fixed error with anchored plots and genomic feature width equals 1bp
* y-axis does respect cex.axis parameter
* GUI fixed to work with shiny 0.11.0 and above


CHANGES IN VERSION 1.0.0
--------------------------------------------------------------------------------

PACKAGE:

* plotHeatmap function returns cluster report as GRanges structure
* redundant parameters removed from plotting functions
* plotHeatmap function have "embed" parameter for plotHeatmap - allows to 
  plot 1st heatmap without using grid system, intended to use with complex plots

BUGFIX:

* motif plot orientation properly dependents on strand
* GUI - reordering the heatmap respects previously set include/exclude 
  parameters


CHANGES IN VERSION 0.99.1
--------------------------------------------------------------------------------

PACKAGE:

* heatmap plotting function returns cluster report ad data.table
* getPlotSetArray function have "verbose" parameter that controls messages 
  and warnings output
* references added to documentation


BUGFIX:

* plotHeatmap and plotAverage generic methods for SeqPlots-classes respect the
  parameters
* package passes tests and check on 32bit Windows (plotting only, because
  no rtrackalyer::BigWigFile support for Win32)


CHANGES IN VERSION 0.99
--------------------------------------------------------------------------------

GENERAL:

* Anchored plots and heatmaps uses [downstream]--0--0--[upstream] X-axis 
  coordinate system instead [downstream]--0--[anchored]-[upstream+anchored]

PACKAGE:

* package really on reference class system including MotifSetup, PlotSetArray, 
  PlotSetList and PlotSetPair
* generic subset and data manipulation methods for SeqPlots-classes including 
  '[', "[[" and "unlist", which allows to switch between classes
* automatic tests for class system, calculations and plotting functions
* documentation for all functions and classes
* PDF vignette engine replaced by HTML one
* QuickStart vignette added

GUI:

* automated GUI tests using Rselenium package

BUGFIX:

* issue #1: some server instances loads empty .Rdata file on startup


CHANGES IN VERSION 0.9.3
--------------------------------------------------------------------------------

* The web GUI and R package projects merged into singe project distributed as 
  Bioconductor compatible R package
* The command line interface have the same capabilities as GUI version
* Web GUI vignette added


CHANGES IN VERSION 0.9.2
--------------------------------------------------------------------------------

GENERAL:

* use Cairo package for plotting, X11 installation no longer required
* colors in plot grid are initiated automatically (same color palette as for 
  auto-generated average plots), white color is allowed
* more informative error messages during file upload
* documentation is integrated with SeqPlots GUI help
* Web GUI debug console added
* Exit button, that closes web interface and background R process

BUGFIX:

* fixed errors reporting in singe core/Windows mode
* the custom color gradient controls for hetmap (three color pickers) work 
  correctly now
* heatmap main title no longer overlaps with sub-plot labels


CHANGES IN VERSION 0.9.1
--------------------------------------------------------------------------------

GENERAL:

* inputs and features sorted alphabetically
* DataTables v1.10.0 with pagination, selection number indicator and 
  infinite row selections
* buttons for heatmap and lineplots, PDF default sizes, 
* changes in GUI layout
* default PDF output paper size set to A4 horizontal, 
* Font sizes are in points
* preview is compatible with A4 PDF output (at 100 DPI)
* color key for heatmap are always generated using image.plot function that 
  provides better labeling
* batch plots do not override individual labels if set
* option to keep 1:1 aspect ratio (default for batch plots)
* miscellaneous options renamed for clarity


CHANGES IN VERSION 0.9.0
--------------------------------------------------------------------------------

FEATURES:

* Multi-plot grid option in batch mode - many line plots on single page

GENERAL:

* R 3.1 and BioC 2.14 compatibility
* faster BigWig signal retrieval, no need for modified rtracklayer C code 
  in the package
* warning message if JS File API is not supported (old browsers)
* improved the performance of heatmap plotting by using list of matrices 
  instead concatenated matrix

BUGFIX:

* application start properly without any BSGenome genomic packages installed
* cluster report - the final order agrees with cluster indicates


CHANGES IN VERSION 0.8.2
--------------------------------------------------------------------------------

FEATURES:

* Hierarchical and super self-organizing network clustering added for heatmaps
* Anchored motif plots
* The row order of the heatmap is exported along with cluster report

GENERAL:

* JS color picker added for browsers, that do not support select input 
  type="color" i.e. Firefox (checked with modernizr.js library)
* Single process mode and Microsoft Windows compatibility (running without fork 
  parallelization)
* Shiny 0.9.1 compatibility
* Saved datasets can be downloaded for local usage
* Clicking row or column name in plot grid toggles the checkboxes
* Minor GUI changes


CHANGES IN VERSION 0.8.1
--------------------------------------------------------------------------------

GENERAL:

* GUI redesign: plot matrix incorporates sub-plot/heatmap specific controls,
  all heatmap options gathered in single tab
* warning before closing/refreshing a webpage with active session
* cookie based default options: user, genome and deactivate page exit warning
* heat-map clusters provided as cluster report - a CSV file containing original 
  features, annotations and cluster information, see more: 
  https://bitbucket.org/przemol/seqplots/wiki/Heatmaps#markdown-header-cluster-report
* Wiggle files processing: correct for multiple header definitions and 
  roman/arabic chromosome names correction 
* Optimised keyboard shortcuts: plot - RETUTRN or ctrl/cmd+SPACE, switch 
  heatmap - ctrl/cmd+H, switch reactive plotting - ctrl/cmd+R
* minor speed improvement

BUGFIX:

* Motif density plots and heatmaps: flip rows on (-) strand


CHANGES IN VERSION 0.8.0
--------------------------------------------------------------------------------

GENERAL:

* GUI redesign, option partitioned to more tabs
* preview plot is zoomed on click rather than on mouse hover
* possibility to remove multiple files
* comments visible as popup in file managmed window
* all chromosome naming conventions (most notably chrX/X and variants 
  of chrM/M/MtDNA/MT etc.) are accepted 
  (http://www.bioconductor.org/packages/release/data/annotation/html/seqnames.db.html)
* incoming featurefiles (GFF and BED) are not processed, just chacked for errors
* explicit error handling for incoming flies, the line with problem or 
  unexpected chromosome(s) are indentified to the user
* motif density tracks can be binned (defoult at 10bp)
* tracks amd motif densities cna be mixed together in plots

SERVER:

* server_config.R added - a configuration file that allows to set up server 
  varaiables, e.g. the user data location

MAC OS X APP:

* interface to insrall new genomes from Bioconductor and local resources 
  (R BSgemome format: 
  http://www.bioconductor.org/packages/release/bioc/html/BSgenome.html)
* option to set up data location


CHANGES IN VERSION 0.7.0
--------------------------------------------------------------------------------

* SeqPlots for Mac OS X relesed - an user frienddly wrapper app containig R, 
  packages and SeqPlots coede
* heatmap plotting added
* motif denstty plotting added for lineplot and heatmap
* minior interface redesign
* reactive interface can be turn off for plottting, user plots on demend
* adding files from jQuery File Upload 
  (http://blueimp.github.io/jQuery-File-Upload/) 
  is handled directly by R eliminating additional node.js server application 
  and making proper file handling for desktop version
* computationally expensive operations (calculating plot matrix and plotting) 
  are handeled by new R process (parallel R library) - many proces can run 
  simmutainously in same Shiny instance, user can get fedback from the 
  calcualtion can be cancelled


CHANGES IN VERSION 0.6.0
--------------------------------------------------------------------------------

* Shiny (https://github.com/rstudio/shiny) used as R web fraimwork, support 
  for Rserver/EXT JS version dropped
* support for 145 genomes from UCSC database (via user provideing valid 
  genome symbol)
* new reactive user interface
* new plot type: midpoint features - it calculates the middle of given 
  features and centres the summary on it
* the option to ignore the strand (plot always in the same direction)
* the option to remove the zeros (0 value of score in Wiggle track) from mean 
  and error estimate calculations
* the support for BED feature files (in addition to GFF, Wiggle (all variants), 
  BigWiggle)
* automatic chromosome name correction for C. elegans genomes 
  (I => chrI, MtDNA => chrM, etc.)
* accepts wiggle with overlapping ranges (e.g. microarray 
  experiments processed using MA2C)
* basic user management for uploaded files
* option to download the features and track files directly from application


CHANGES IN VERSION 0.5.0
--------------------------------------------------------------------------------

* Initial test and alpha releases
