# Fityk – version adaptée pour le chercheur

Fityk 1.3.2 (logiciel de fit de pics : on charge un spectre X/Y, on sélectionne
les zones actives, on ajoute des gaussiennes, on fit) avec les modifications
demandées. Le chercheur travaille sur **Mac**, spectres **calibrés en énergie**.

---

## 1. Lancer le logiciel (test local)

L'application est déjà packagée : **`dist/Fityk.app`**.

```bash
open dist/Fityk.app
# ou en chargeant directement un fichier de données :
open dist/Fityk.app --args "$PWD/data/Ar9_RUN003-cal.dat"
```

`Fityk.app` est **autonome** (toutes les bibliothèques – wxWidgets, xylib, lua,
libfityk – sont embarquées dans `Contents/libs`). On peut la copier sur une
autre machine Mac de **même architecture** (ici Apple Silicon / arm64).

> Au premier lancement sur la machine du chercheur, macOS (Gatekeeper) peut
> bloquer une app non notariée : **clic droit sur Fityk.app → Ouvrir → Ouvrir**.
> (À faire une seule fois.)

---

## 2. Ce qui a été modifié (6 points)

### a) Verrouiller le centre (ou tout paramètre) à ± une valeur choisie
Dans le panneau des paramètres (barre latérale, onglet *functions*, sélectionner
un pic) : **clic droit sur le paramètre** (ex. `center`) →
**« Lock center within ± range… »** → saisir la tolérance (ex. `0.1`).
Le paramètre reste **libre de bouger uniquement dans [valeur−δ ; valeur+δ]**
pendant le fit. Un marqueur `±0.1` apparaît à côté du nom du paramètre.
Pour retirer : clic droit → **« Remove range constraint »**.

Workflow typique : régler le centre sur 255 (taper la valeur), puis clic droit →
± 0.1. La borne est réellement respectée par le fit (voir point *f*).

### b) Aucune fonction négative (activé par défaut)
Menu **Functions → « Non-negative peaks »** (coché par défaut). Quand c'est
actif, la **hauteur de chaque pic est contrainte ≥ 0** avant chaque fit :
l'optimiseur ne peut plus rendre un pic négatif. Le réglage est mémorisé entre
deux sessions.

### c) Largeur en FWHM (pleine largeur à mi-hauteur) au lieu de HWHM
Dans le panneau des paramètres, la largeur des gaussiennes s'appelle maintenant
**`fwhm`** et affiche/attend la **pleine largeur** (= 2 × hwhm). Plus besoin de
diviser par 2. (La colonne *FWHM* de la liste et l'info du pic étaient déjà en
FWHM ; c'est le champ éditable qui manquait.)
Le bouton **`=W`** (« same width (FWHM) for all functions ») impose la même
largeur à tous les pics ; **désactivé** (état par défaut) chaque pic garde sa
largeur libre.

### d) Raccourcis clavier Mac standard
- **⌘W** : fermer la fenêtre — **⌘M** : réduire (menu *Window*)
- **⌘C / ⌘V / ⌘X / ⌘A** : copier / coller / couper / tout sélectionner (menu *Edit*)

Ces raccourcis étaient auparavant « volés » par des fonctions du logiciel
(⌘V = zoom vertical, ⌘M = charger fichier, ⌘A = zoom, ⌘X = exécuter script).
Sur Mac ces accélérateurs ont été retirés et rendus aux raccourcis système.

### e) Export : bonnes colonnes pré-cochées
**Data → Export Points** (⌘S) propose désormais par défaut :
**points actifs uniquement** (la plage sélectionnée), **x, y, tous les
composants du modèle, le modèle (somme) et les résidus**. Il reste possible de
cocher/décocher.

### f) Méthode de fit = mpfit (Levenberg-Marquardt avec bornes)
La méthode de fit par défaut est maintenant **mpfit** au lieu du LM « maison ».
C'est le **même algorithme** (Levenberg-Marquardt, issu de MINPACK) mais il
**respecte les bornes** (domaines) des paramètres — indispensable pour que les
points *a)* et *b)* soient réellement appliqués pendant le fit. On peut toujours
changer de méthode dans **Fit → Method**.

---

## 3. Reconstruire depuis les sources

Voir **`dist/BUILD_MAC.md`**. En résumé, une fois les
dépendances installées :

```bash
make -j4            # recompile ; le binaire est wxgui/fityk (wrapper)
./dist/make_app.sh  # (re)fabrique dist/Fityk.app autonome
```

---

## 4. Fichiers source modifiés

| Fichier | Modification |
|---|---|
| `fityk/settings.cpp` | méthode de fit par défaut → `mpfit` |
| `wxgui/exportd.cpp` | colonnes d'export par défaut (actifs + composants + modèle + résidus) |
| `wxgui/frame.cpp` / `frame.h` | option « Non-negative peaks », menus Edit/Window Mac, raccourcis |
| `wxgui/sidebar.cpp` / `sidebar.h` | affichage/saisie FWHM, menu contextuel « lock ± » |
| `wxgui/parpan.cpp` / `parpan.h` | échelle d'affichage par ligne (FWHM), clic droit sur les paramètres |

Aucun autre comportement n'a été modifié.
