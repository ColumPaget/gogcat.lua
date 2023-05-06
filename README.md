SYNOPSIS
========

gogcat.lua is a command-line search tool for finding games on GOG's catalog.gog.com service. It's written in lua (https://www.lua.org) and requires libUseful (https://github.com/ColumPaget/libUseful) and libUseful-lua (https://github.com/ColumPaget/libUseful-lua) to be installed. libUseful-lua requires swig (https://www.swig.org) installed for building.

LICENSE
=======

gogcat.lua is released under the GPLv3 license.

AUTHOR
======

gogcat.lua is (C) 2023 by Colum Paget.


RUNNING 
=======

The script 'gogcat.lua' can either be run as 'lua gogcat.lua' or linux's "binfmt" system can be used to invoke lua automatically when the script is run.


USAGE
=====

```
  gogcat.lua -?                          - print this help
  gogcat.lua -h                          - print this help
  gogcat.lua -help                       - print this help
  gogcat.lua --help                      - print this help
  gogcat.lua show tags                   - list all tags
  gogcat.lua show genres                 - list all genres
  gogcat.lua show features               - list all game features
  gogcat.lua show systems                - list all operating systems
  gogcat.lua [options] <search term>     - search catalog
```


SEARCH OPTIONS
==============

```
  -debug         output debugging
  -p <min>,<max> show products in price range
  -t <tags>      show products matching tags
  -g <genres>    show products matching genres
  -f <features>  show products matching features
  -new           show products that are new releases
  -soon          show products that are upcoming releases
  -sale          show products on sale
  -onsale        show products on sale
  -win           show products for windows
  -lin           show products for linux
  -osx           show products for mac osx
  -game          show products that are games
  -dlc           show products that are DLC for games
  -pack          show products that are packs of multiple games
  -loc <locale>  use <locale> where <locale> is <locale_code>:<country_code>:<currency_code>  e.g. en:GB:GBP
```


EXAMPLES
========

```
  gogcat.lua -loc en:GB:GBP  darkest dungeon       - search for darkest dungeon, return results in pounds for the UK
  gogcat.lua -loc de:DE:EUR  darkest dungeon       - search for darkest dungeon, return results in euros for germany
  gogcat.lua -g strategy -p 0,4 -loc en:GB:GBP     - search for strategy games under four UK pounds
  gogcat.lua -g strategy -osx                      - search for strategy games for mac OSX
  gogcat.lua -new -onsale                          - search for new releases that are also on sale
  gogcat.lua -game -new -lin                       - search for new releases that are linux games
  gogcat.lua -dlc -new                             - search for new releases that are DLC
```
