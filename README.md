# Global Game Jam 2025
Theme: Bubbles

## Building
### Requirements
- [git](https://git-scm.com/)
- [npm](https://www.npmjs.com/)
- [lua](https://www.lua.org/)
- [luarocks](https://luarocks.org/)

### Lua requirements (installed using luarocks)
- [teal](https://github.com/teal-language/tl)
- [cyan](https://github.com/teal-language/cyan)
- [pegasus](https://github.com/EvandroLG/pegasus.lua)
- [sha1](https://github.com/mpeterv/sha1)
- [base64](https://github.com/iskolbin/lbase64)

### Instant setup guide
Assuming all of the requirements are properly installed, then the following should clone, build, and run the template locally on `localhost:8080` from scratch.
(Only tested on linux - your mileage may vary).
```sh
git clone git@github.com:RiFactor/global-game-jam-25.git
cd global-game-jam-25
npm i
npm start
```

### Commands
- `npm run copy` will copy all necessary assets from `src/assets` to `dist/assets`.
- `npm run build` will rebuild all javascript and teal, and copy everything over to `dist`.
- `npm run run` will run the server without rebuilding or copying anything.
- `npm start` builds and copies everything, and then runs the server.
