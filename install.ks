//Boot script for Launch Alpha
CLEARSCREEN.

Print "Initilizing and installing to Drive 1".
SWITCH TO 1.

//Reinstall script setup
Print "Installing reinstall script".
COPY reinstall FROM ARCHIVE.
Print "Initilizing reinstall script".

print " ".

Print "Installing LA Primary Library".
COPY LA FROM ARCHIVE.
Print "Installing LA Assistance Libraries.".
COPY LA_Functions FROM ARCHIVE.
COPY LA_CraftSettings FROM ARCHIVE.
//Run Functions to pull required data to program.
run LA_Functions.

Print lName + " " + lVersion + " Installed.".
Print "".
Print "Launch Aplha Copied to Craft. Run with 'RUN LA.'".
Print TestFunction().
