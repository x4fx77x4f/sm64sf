# SM64SF

This is an **unofficial** port of Nintendo's *Super Mario 64* to [StarfallEx](https://github.com/thegrb93/StarfallEx). Almost everything has been translated manually. **It is extremely early in development and currently does not do anything exciting.**

![Screenshot](https://user-images.githubusercontent.com/70858634/118589730-f8008000-b76e-11eb-9c90-0c3befbd37be.png)

## Roadmap

- [x] Execute until end of intro
- [ ] Display copyright info
- [ ] Display 3D logo
- [ ] Display Mario head background
- [ ] Display Mario head
- [ ] Properly light Mario head
- [ ] Handle controller input
- [ ] Start new game
- [ ] Spawn in level
- [ ] Move around level
- [ ] ...
- [ ] 100% complete one day?

## Usage

1. `git clone https://github.com/x4fx77x4f/sm64sf.git sm64sf`
2. `git clone https://github.com/n64decomp/sm64.git sm64`
3. Place an unmodified *Super Mario 64* (only tested with U.S. version) ROM file in `sm64/baserom.us.z64`.
4. `cd sm64 && ./extract_assets.py us && cd ..`
5. `./sm64sf/copy_assets.sh sm64 sm64sf`
6. `ln -s "$PWD/sm64sf" ~/.steam/steam/steamapps/common/GarrysMod/garrysmod/data/starfall/sm64sf`
7. `ln -s "$PWD/sm64sf" ~/.steam/steam/steamapps/common/GarrysMod/garrysmod/data/sf_filedata/sm64sf`
8. Flash `sm64sf/init.lua` to a chip and connect a screen to it.

## License

This project is primarily derived from [sm64js](https://github.com/sm64js/sm64js) and [n64decomp/sm64](https://github.com/n64decomp/sm64). Those projects and this project are all originally derived from Nintendo's proprietary Super Mario 64. The overwhelming majority of the content in these repositories is non-free for this reason, regardless of any license they may have been claimed to be released under.

While this project is without a doubt non-free, an effort has been made to reduce the amount of Nintendo-owned content in this repository. **Most** non-code assets such as textures, models, and sounds are not included and must be extracted from a ROM file. Absolutely nothing in this repository is based on the leaked source code for Super Mario 64 **to my knowledge**.

This project may include a small amount of entirely original code, for which I would be willing to package separately under a free license if requested.
