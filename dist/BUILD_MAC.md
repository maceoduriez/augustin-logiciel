# Construire Fityk (GUI) sur macOS

Étapes exactes utilisées pour produire `dist/Fityk.app` (macOS, Apple Silicon).
Le build **GUI** utilise les autotools (le `CMakeLists.txt` ne construit que la
lib + le CLI, pas l'interface).

## 1. Dépendances (Homebrew)

```bash
brew install automake autoconf libtool pkg-config swig lua wxwidgets boost dylibbundler
```

## 2. xylib (pas de formule Homebrew — compilé depuis les sources)

```bash
git clone --depth 1 https://github.com/wojdyr/xylib.git /tmp/xylib-build
cd /tmp/xylib-build
./autogen.sh   # échoue à la fin (chemin Boost), sans gravité
./configure --without-gui --disable-static --prefix=$HOME/.local \
    CPPFLAGS="-I/opt/homebrew/include" LDFLAGS="-L/opt/homebrew/lib"
make -j4 && make install     # installe dans ~/.local
```

## 3. Fityk

Depuis la racine du dépôt :

```bash
./autogen.sh   # échoue à la fin (Boost/lua), sans gravité — il génère ./configure

./configure --disable-python --with-wx-config=/opt/homebrew/bin/wx-config \
    CPPFLAGS="-I$HOME/.local/include -I/opt/homebrew/include -I/opt/homebrew/include/lua" \
    LDFLAGS="-L$HOME/.local/lib -L/opt/homebrew/lib"

make -j4
```

Binaires produits :
- `wxgui/fityk`   — GUI (wrapper libtool qui règle les chemins des libs)
- `cli/cfityk`    — version ligne de commande (pratique pour tester : `./cli/cfityk`)

Lancer la GUI en local (via le wrapper, sans packaging) :
```bash
./wxgui/fityk data/Ar9_RUN003-cal.dat
```

## 4. Packager l'application autonome

```bash
./dist/make_app.sh      # -> dist/Fityk.app (libs embarquées, signature ad-hoc)
```

## Notes
- Lua 5.5 est détecté (le dépôt contient déjà le correctif « Detect Lua 5.5 »).
- Pour une distribution « propre » chez le chercheur : idéalement signer avec un
  Developer ID + notariser. À défaut, le premier lancement se fait par
  clic droit → Ouvrir.
- `dist/` ne contient que des artefacts générés (non suivis par git).
