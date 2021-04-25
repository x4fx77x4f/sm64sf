# SM64SF
This is an **unofficial** port of Nintendo's *Super Mario 64* to [StarfallEx](https://github.com/thegrb93/StarfallEx). Almost everything has been translated manually.

![Screenshot](https://user-images.githubusercontent.com/70858634/115991094-d7407280-a594-11eb-81ca-6830868f193c.png)

## Usage
1. `git clone https://github.com/x4fx77x4f/sm64sf.git sm64sf`
2. `git clone https://github.com/n64decomp/sm64.git sm64`
3. Place an unmodified *Super Mario 64* (only tested with U.S. version) ROM file in `sm64/baserom.us.z64`.
4. `cd sm64 && ./extract_assets.py us && cd ..`
5. `./sm64sf/copy_assets.sh sm64 sm64sf`
6. `ln -s "$PWD/sm64sf" ~/.steam/steam/steamapps/common/GarrysMod/garrysmod/data/starfall/sm64sf`
7. `ln -s "$PWD/sm64sf" ~/.steam/steam/steamapps/common/GarrysMod/garrysmod/data/sf_filedata/sm64sf`
8. Flash `sm64sf/init.lua` to a chip and connect a screen to it.

## Completion
It makes it to the end of the "It's-a me, Mario!" intro before crashing, but doesn't render anything or make any sound.

## License
This project may contain code from [n64decomp/sm64](https://github.com/n64decomp/sm64), [sm64-port](https://github.com/sm64-port/sm64-port), [sm64ex](https://github.com/sm64pc/sm64ex), and [sm64js](https://github.com/sm64js/sm64js). These projects are all proprietary and originally derived from Nintendo's proprietary Super Mario 64.

While this project is without a doubt non-free, an effort has been made to reduce the amount of Nintendo-owned content in this repository. Most non-code assets such as textures, models, and sounds are not included and must be extracted from a ROM file. Absolutely nothing in this repository is based on the leaked source code for Super Mario 64 (to my knowledge).

This project also includes *some* original code for which I would be willing to package separately under a free license if requested.
