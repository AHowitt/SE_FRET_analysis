1- run LCU_FRET_initialise
2- choose .nd2 file prompted by software
3- input (dialog boxes pop up) correct values for 1) capture interval 2) number of groups/conditions 3) select groups (if not already done so appropriately by default, which is division of all FOVs by number of groups)
4- change donor channel to 2 and acceptor to 1
5- at this point you have to open 'LCI_FRET_process.m' and run it
6 - that will close the channels box and ask you for file location to save (saves by default into image file directory)

Make sure to change variable 'qc_ti' in LCI_FRET_initialise depending on the length of the experiment. 
'qc_ti' determines the length of timepoints by which you want the cells to be picked up in the end analysis.