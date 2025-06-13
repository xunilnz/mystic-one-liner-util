# mystic-one-liner-util
Mystic BBS One-Liner Utility

This utility was inspired by a situation as a BBS Sysop where 
a user had left an inappropriate entry on the One-Liner that
needed to be removed. There is no way to do this within the 
BBS utilities today so this tool was built to fill that gap.

It allows you to List then Delete any entry that you would like
to remove. It has been tested on Windows but not on Linux
at the time of this writing, but was compile tested on a Mac
so there should be no issues. If you reach out with specific
flavors of Unix you would like, I can do my best to provide
binaries but otherwise all of the code is here to generate 
one for whichever OS targets you wish.

# To Compile
 You will also need https://github.com/rickparrish/RMDoor
 in the parent directory prior to running molu.sh to compile

 ./molu.sh will compile MysticOLUtil

 # To Install

 Once it compiles, cp ./MysticOLUtil [mysticdir]
 
 or symlink it. Ideal if you recompile, you won't need to 
 copy it over again.
 
ln -sf "$(pwd)"/MysticOLUtil [mysticdir]/MysticOLUtil 

 Replace [mysticdir] with the actual location of your Mystic BBS
 installation. 

 eg:  ln -sf "$(pwd)"/MysticOLUtil /home/mystic/MysticOLUtil

 The output of the original code for MysticOLUtil needs to be in the
 same location as oneliner.dat, This fork allows you to put MysticOLUtil 
 into your root Mystic BBS directory with the rest of the binaries.

