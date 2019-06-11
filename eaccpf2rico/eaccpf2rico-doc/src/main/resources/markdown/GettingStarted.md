# Getting Started

## Common Problems

### Error occurred during initialization of VM, could not reserve enough space for xxxxxx object heap

This error indicates that your machine does not have enough memory to run the conversion script. To deal with this you can try to lower the amount of memory used by the script. For this :

- edit in a text editor the script `eac2rico.bat`
- Toward the end of the script, spot the line where the java executable is run; it look like `SET fullCommandLine=java -Xmx2048M -Xms1024M -jar eaccpf2rico-cli..........`
- `-Xmx` sets the _maximum_ amount of memory for the Java virtual machine, and `-Xms` sets the _starting_ amount of memory for the Java virtual machine. Try to lower both figures, to e.g. `-Xmx1024M -Xms500M`. The script will run lower, but should be fine; try however to remain above 1024M of maximum memory, otherwise this could potentially result in OutOfMemoryErrors during the script.

