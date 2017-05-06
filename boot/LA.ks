//Boot script for Launch Alpha
CLEARSCREEN.
SET VOLUME(1):NAME TO "SHIPDRIVE".

Print "Initilizing and installing to Drive 1".
SWITCH TO 1.

//Reinstall script setup
Print "Installing reinstall script".
COPYPATH("ARCHIVE:/reinstall.ks","SHIPDRIVE:/reinstall.ks").

print " ".

Print "Installing LA".
COPYPATH("ARCHIVE:/LA.ks","SHIPDRIVE:/LA.ks").
COPYPATH("ARCHIVE:/LA_Functions.ks","SHIPDRIVE:/LA_Functions.ks").
COPYPATH("ARCHIVE:/LA_CraftSettings_2stage.ks","SHIPDRIVE:/LA_CraftSettings_2stage.ks").

//Run Functions to pull required data to program.
run LA_Functions.
print " ".
Print lName + " " + lVersion + " Installed.".
Print "".
Print "Launch Aplha Copied to Craft. Run with 'RUN LA.'".
