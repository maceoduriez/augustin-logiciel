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

## 2. Ce qui a été modifié

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

### g) Couleurs correctes quand on enchaîne les sessions
Les couleurs (fonctions et datasets) sont réinitialisées à chaque
**Session → Load Session** : charger une deuxième session sans fermer le
logiciel n'hérite plus des couleurs de la première. Les couleurs enregistrées
dans le fichier de session sont ensuite réappliquées.

### h) Raccourcis pour les sessions
- **⌘⇧O** : charger une session (*Session → Load Session*)
- **⌘⇧S** : enregistrer la session (*Session → Save Session*)

(⌘O et ⌘S restent réservés aux données : chargement / export.)

### i) Confirmation à la fermeture
Si la session contient des changements non enregistrés, fermer la fenêtre (ou
⌘Q / ⌘W) demande d'abord **Enregistrer / Ne pas enregistrer / Annuler**, comme
Excel ou PowerPoint.

### j) Décimales des caractéristiques + séparateur de milliers
Dans l'onglet *functions* de la barre latérale, le bouton **« 0.0 »** ouvre
**« Décimales affichées »** : pour chaque grandeur (Centre, Hauteur, Aire,
FWHM, Autres), choisir *auto* ou un nombre de décimales (ex. Centre à 2
décimales, Aire arrondie à l'unité). S'applique à la liste des fonctions, au
panneau d'info du pic et aux étiquettes sur le graphe. Les milliers sont
toujours séparés par une espace (**1 235** au lieu de 1235). Réglage mémorisé.

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
| `wxgui/mplot.cpp` / `mplot.h` | réinitialisation des couleurs au changement de session, étiquettes de pics formatées |
| `wxgui/cmn.cpp` / `cmn.h` | formateur décimales + séparateur de milliers |
| `wxgui/app.cpp` | marquage « session modifiée » après chaque commande |

Aucun autre comportement n'a été modifié.
