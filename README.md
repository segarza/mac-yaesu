# mac-yaesu
Bash script to identify correct Yaesu Radio device file on macOS (/dev/cu.SLAB_USBtoUART)

This script was created to address the annoying task of identifying the correct /dev/cu.SLAB_USBtoUARTx for Yaesu FT-891 & FT-991A radios attached to a Mac running macOS Monterrey. These values often change across reboots.

This script requires Hamlib to be installed on the system. Hamlib can be easily installed using homebrew (https://brew.sh): brew install hamlib

 
If flrig is installed and enabled (see user configurable settings), the script will launch an instance per radio. 
flrig must have been manually launched and initially configured once per radio prior to enabling flrig in the user configurable settings. 
To manually launch flrig– Open terminal and type: open -a /Applications/flrig.app --args --config-dir ~/Documents/Yaesu/891 (or 991A)
The folders ~/Documents/Yaesu/891 & ~/Documents/Yaesu/991A must be manually created by the user prior to running the above command.
The script will update the corresponding flrig radio preferences with the correct device file (/dev/cu.SLAB_USBtoUARTx). 
flrig can also be installed with homebrew: brew install --cask flrig

When enabled, the script will launch rigctld instance per radio. The FT-891 will be assigned port 4532 and the FT-991A will be assigned port 4533.
