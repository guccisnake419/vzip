# VZIP


#### This project might be buggy, unstable and unable to handle larger zip capacity


A description of this package.
```
 __     __  _____  ___   ____  
 \ \   / / |__  / |_ _| |  _ \ 
  \ \ / /    / /   | |  | |_) |
   \ V /    / /_   | |  |  __/ 
    \_/    /____| |___| |_|                                 
USAGE: vzip [--list <list>] [--zip <zip> ...] [--unzip <unzip> ...] [--remove <remove> ...] [--concat <concat> ...] [--no_deflate]

OPTIONS:
  -l, --list <list>       Lists the contents of an archive (e.g., --list <from>)
  -z, --zip <zip>         Zip an archive (e.g., --zip <from> <to>)
  --unzip <unzip>         Unzip an archive (e.g., --unzip <from> <to>)
  -r, --remove <remove>   Remove a file from an archive (e.g., --remove <from> <file_to_remove>)
  -c, --concat <concat>   Concatenate two archives (e.g., --concat <archive_1> <archive_2> <combination_archive>)
  --no_deflate            Use deflate compression method
  -h, --help              Show help information.
```


About the Zip file format
https://en.wikipedia.org/wiki/ZIP_(file_format)#Encryption

### Installation

MacOS

From Executable
```
#Rename the executable to vzip
sudo mv <pathtobin> /usr/local/bin
which vzip

```

From Source Code 
```
git clone https://github.com/guccisnake419/vzip.git
swift build -c release
swift build -c release --show-bin-path #location of the executable
sudo mv <pathtorelase>/vzip /usr/local/bin
```

