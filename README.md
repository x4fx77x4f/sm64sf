# SM64SF
This is an **unofficial** port of Nintendo's *Super Mario 64* to [StarfallEx](https://github.com/thegrb93/StarfallEx). Almost everything has been translated manually.

![Screenshot](https://user-images.githubusercontent.com/70858634/115682705-b9b8a200-a323-11eb-94d9-2b92a032b4e8.png)

## Usage
1. `git clone https://github.com/n64decomp/sm64.git`
2. Place an unmodified *Super Mario 64* (only tested with U.S. version) ROM file to `baserom.us.z64`.
3. `./extract_assets.py us`
4. `./copy_assets.sh wherever/you/put/n64decomp/sm64`

## Completion
It makes it to the end of the "It's-a me, Mario!" intro before crashing, but doesn't render anything or make any sound.

## License
This project may contain code from [n64decomp/sm64](https://github.com/n64decomp/sm64), [sm64-port](https://github.com/sm64-port/sm64-port), and [sm64ex](https://github.com/sm64pc/sm64ex). These projects are all proprietary and originally derived from Nintendo's proprietary Super Mario 64.

While this project is without a doubt non-free, an effort has been made to reduce the amount of non-free content in this repository. Most non-code assets such as textures, models, and sounds are not included and must be extracted from a ROM file. Absolutely nothing in this repository is based on the leaked source code for Super Mario 64 (to my knowledge).

This project also includes *some* original code for which I would be willing to package separately under a free license if requested.
