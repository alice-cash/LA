//Boot script for Launch Alpha
CLEARSCREEN.

Print "Initilizing and installing to Drive 1".
SWITCH TO 1.

//Reinstall script setup
Print "Installing reinstall script".
COPY reinstall FROM ARCHIVE.

print " ".

Print "Installing LA".
COPY LA FROM ARCHIVE.
COPY LA_Functions FROM ARCHIVE.
COPY LA_CraftSettings FROM ARCHIVE.
//Run Functions to pull required data to program.
run LA_Functions.
print " ".
Print lName + " " + lVersion + " Installed.".
Print "".
Print "Launch Aplha Copied to Craft. Run with 'RUN LA.'".
