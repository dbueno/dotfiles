{
  # https://github.com/joshbenham/linux-dotfiles/blob/master/dircolors/Dracula.dircolors
  ## Documentation
  #
  # standard colors
  #
  # Below are the color init strings for the basic file types. A color init
  # string consists of one or more of the following numeric codes:
  # Attribute codes:
  # 00=none 01=bold 04=underscore 05=blink 07=reverse 08=concealed
  # Text color codes:
  # 30=black 31=red 32=green 33=yellow 34=blue 35=magenta 36=cyan 37=white
  # Background color codes:
  # 40=black 41=red 42=green 43=yellow 44=blue 45=magenta 46=cyan 47=white
  #
  #
  # 256 color support
  # see here: http://www.mail-archive.com/bug-coreutils@gnu.org/msg11030.html)
  #
  # Text 256 color coding:
  # 38;5;COLOR_NUMBER
  # Background 256 color coding:
  # 48;5;COLOR_NUMBER

  ## Special files

  NORMAL = "00;38;5;15"; # no color code at all
  #FILE 00 # regular file: use no color at all
  RESET = "0"; # reset to "normal" color
  DIR = "00;38;5;6"; # directory 01;34
  LINK = "00;38;5;2"; # symbolic link. (If you set this to 'target' instead of a
  # numerical value, the color is as for the file pointed to.)
  MULTIHARDLINK = "00"; # regular file with more than one link
  FIFO = "48;5;0;38;5;3;01"; # pipe
  SOCK = "48;5;0;38;5;3;01"; # socket
  DOOR = "48;5;0;38;5;3;01"; # door
  BLK = "48;5;0;38;5;15;01"; # block device driver
  CHR = "48;5;0;38;5;15;01"; # character device driver
  ORPHAN = "48;5;0;38;5;1"; # symlink to nonexistent file, or non-stat'able file
  SETUID = "48;5;1;38;5;3"; # file that is setuid (u+s)
  SETGID = "48;5;1;38;5;3"; # file that is setgid (g+s)
  CAPABILITY = "30;41"; # file with capability
  STICKY_OTHER_WRITABLE = "48;5;2;38;5;3"; # dir that is sticky and other-writable (+t,o+w)
  OTHER_WRITABLE = "48;5;0;38;5;6"; # dir that is other-writable (o+w) and not sticky
  STICKY = "48;5;6;38;5;3"; # dir with the sticky bit set (+t) and not other-writable
  # This is for files with execute permission:
  EXEC = "00;38;5;2";

  ## Archives or compressed (violet + bold for compression)
  ".tar" =    "00;38;5;4";
  ".tgz" =    "00;38;5;4";
  ".arj" =    "00;38;5;4";
  ".taz" =    "00;38;5;4";
  ".lzh" =    "00;38;5;4";
  ".lzma" =   "00;38;5;4";
  ".tlz" =    "00;38;5;4";
  ".txz" =    "00;38;5;4";
  ".zip" =    "00;38;5;4";
  ".z" =      "00;38;5;4";
  ".Z" =      "00;38;5;4";
  ".dz" =     "00;38;5;4";
  ".gz" =     "00;38;5;4";
  ".lz" =     "00;38;5;4";
  ".xz" =     "00;38;5;4";
  ".bz2" =    "00;38;5;4";
  ".bz" =     "00;38;5;4";
  ".tbz" =    "00;38;5;4";
  ".tbz2" =   "00;38;5;4";
  ".tz" =     "00;38;5;4";
  ".deb" =    "00;38;5;4";
  ".rpm" =    "00;38;5;4";
  ".jar" =    "00;38;5;4";
  ".rar" =    "00;38;5;4";
  ".ace" =    "00;38;5;4";
  ".zoo" =    "00;38;5;4";
  ".cpio" =   "00;38;5;4";
  ".7z" =     "00;38;5;4";
  ".rz" =     "00;38;5;4";
  ".apk" =    "00;38;5;4";
  ".gem" =    "00;38;5;4";

  # Image formats (yellow)
  ".jpg" =    "00;38;5;3";
  ".JPG" =    "00;38;5;3";
  ".jpeg" =   "00;38;5;3";
  ".gif" =    "00;38;5;3";
  ".bmp" =    "00;38;5;3";
  ".pbm" =    "00;38;5;3";
  ".pgm" =    "00;38;5;3";
  ".ppm" =    "00;38;5;3";
  ".tga" =    "00;38;5;3";
  ".xbm" =    "00;38;5;3";
  ".xpm" =    "00;38;5;3";
  ".tif" =    "00;38;5;3";
  ".tiff" =   "00;38;5;3";
  ".png" =    "00;38;5;3";
  ".PNG" =    "00;38;5;3";
  ".svg" =    "00;38;5;3";
  ".svgz" =   "00;38;5;3";
  ".mng" =    "00;38;5;3";
  ".pcx" =    "00;38;5;3";
  ".dl" =     "00;38;5;3";
  ".xcf" =    "00;38;5;3";
  ".xwd" =    "00;38;5;3";
  ".yuv" =    "00;38;5;3";
  ".cgm" =    "00;38;5;3";
  ".emf" =    "00;38;5;3";
  ".eps" =    "00;38;5;3";
  ".CR2" =    "00;38;5;3";
  ".ico" =    "00;38;5;3";

  # Files of special interest (base1)
  ".tex" =             "00;38;5;7";
  ".rst" =             "00;38;5;7";
  ".rdf" =             "00;38;5;7";
  ".owl" =             "00;38;5;7";
  ".n3" =              "00;38;5;7";
  ".ttl" =             "00;38;5;7";
  ".nt" =              "00;38;5;7";
  ".torrent" =         "00;38;5;7";
  ".xml" =             "00;38;5;7";
  "*Makefile" =        "00;38;5;7";
  "*Rakefile" =        "00;38;5;7";
  "*Dockerfile" =      "00;38;5;7";
  "*build.xml" =       "00;38;5;7";
  "*rc" =              "00;38;5;7";
  "*1" =               "00;38;5;7";
  ".nfo" =             "00;38;5;7";
  "*README" =          "00;38;5;7";
  "*README.txt" =      "00;38;5;7";
  "*readme.txt" =      "00;38;5;7";
  ".md" =              "00;38;5;7";
  "*README.markdown" = "00;38;5;7";
  ".ini" =             "00;38;5;7";
  ".yml" =             "00;38;5;7";
  ".cfg" =             "00;38;5;7";
  ".conf" =            "00;38;5;7";
  ".h" =               "00;38;5;7";
  ".hpp" =             "00;38;5;7";
  ".c" =               "00;38;5;7";
  ".cpp" =             "00;38;5;7";
  ".cxx" =             "00;38;5;7";
  ".cc" =              "00;38;5;7";
  ".objc" =            "00;38;5;7";
  ".sqlite" =          "00;38;5;7";
  ".go" =              "00;38;5;7";
  ".sql" =             "00;38;5;7";
  ".csv" =             "00;38;5;7";

  # "unimportant" files as logs and backups (base01)
  ".log" =        "00;38;5;8";
  ".bak" =        "00;38;5;8";
  ".aux" =        "00;38;5;8";
  ".lof" =        "00;38;5;8";
  ".lol" =        "00;38;5;8";
  ".lot" =        "00;38;5;8";
  ".out" =        "00;38;5;8";
  ".toc" =        "00;38;5;8";
  ".bbl" =        "00;38;5;8";
  ".blg" =        "00;38;5;8";
  "*~" =          "00;38;5;8";
  "*#" =          "00;38;5;8";
  ".part" =       "00;38;5;8";
  ".incomplete" = "00;38;5;8";
  ".swp" =        "00;38;5;8";
  ".tmp" =        "00;38;5;8";
  ".temp" =       "00;38;5;8";
  ".o" =          "00;38;5;8";
  ".pyc" =        "00;38;5;8";
  ".class" =      "00;38;5;8";
  ".cache" =      "00;38;5;8";

  # Audio formats (orange)
  ".aac" =    "00;38;5;1";
  ".au" =     "00;38;5;1";
  ".flac" =   "00;38;5;1";
  ".mid" =    "00;38;5;1";
  ".midi" =   "00;38;5;1";
  ".mka" =    "00;38;5;1";
  ".mp3" =    "00;38;5;1";
  ".mpc" =    "00;38;5;1";
  ".ogg" =    "00;38;5;1";
  ".opus" =   "00;38;5;1";
  ".ra" =     "00;38;5;1";
  ".wav" =    "00;38;5;1";
  ".m4a" =    "00;38;5;1";
  # http://wiki.xiph.org/index.php/MIME_Types_and_File_Extensions
  ".axa" =    "00;38;5;1";
  ".oga" =    "00;38;5;1";
  ".spx" =    "00;38;5;1";
  ".xspf" =   "00;38;5;1";

  # Video formats (as audio + bold)
  ".mov" =    "00;38;5;1";
  ".MOV" =    "00;38;5;1";
  ".mpg" =    "00;38;5;1";
  ".mpeg" =   "00;38;5;1";
  ".m2v" =    "00;38;5;1";
  ".mkv" =    "00;38;5;1";
  ".ogm" =    "00;38;5;1";
  ".mp4" =    "00;38;5;1";
  ".m4v" =    "00;38;5;1";
  ".mp4v" =   "00;38;5;1";
  ".vob" =    "00;38;5;1";
  ".qt" =     "00;38;5;1";
  ".nuv" =    "00;38;5;1";
  ".wmv" =    "00;38;5;1";
  ".asf" =    "00;38;5;1";
  ".rm" =     "00;38;5;1";
  ".rmvb" =   "00;38;5;1";
  ".flc" =    "00;38;5;1";
  ".avi" =    "00;38;5;1";
  ".fli" =    "00;38;5;1";
  ".flv" =    "00;38;5;1";
  ".gl" =     "00;38;5;1";
  ".m2ts" =   "00;38;5;1";
  ".divx" =   "00;38;5;1";
  ".webm" =   "00;38;5;1";
  # http://wiki.xiph.org/index.php/MIME_Types_and_File_Extensions
  ".axv" = "00;38;5;1";
  ".anx" = "00;38;5;1";
  ".ogv" = "00;38;5;1";
  ".ogx" = "00;38;5;1";
}
