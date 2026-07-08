# Fityk + — Limites du fit contraint & protocole de convergence

Testé sur le moteur réel (mpfit = Levenberg-Marquardt avec bornes) avec le
spectre `Ar9_RUN003-cal.dat`. Chaque limite ci-dessous a été reproduite.

## Ce qui fait « mourir » un fit (limites du programme)

### 1. Une valeur initiale hors de sa fenêtre ± — LA cause n° 1
Si un paramètre vaut p.ex. 260 alors que sa contrainte est [254.9 : 255.1],
le fit s'arrête **immédiatement** (1 seule évaluation) avec le message
`Initial values inconsistent w constraints` — et un WSSR affiché à 0.
Rien ne bouge : on a l'impression que « ça ne converge plus ».

**Comment ça arrive** : la contrainte ± reste attachée au paramètre quand on
retape sa valeur ou qu'on la modifie à la molette/glissière. Il suffisait
donc de déplacer un centre verrouillé pour tout casser.

**→ Corrigé dans la version r6** : si on retape une valeur hors fenêtre, la
fenêtre ± se déplace avec la valeur (même demi-largeur) ; et avant chaque
fit, tout paramètre hors de sa fenêtre est ramené à la borne la plus proche
avec un avertissement dans la console. Ce mode d'échec ne devrait plus se
produire.

### 2. Des fenêtres ± trop étroites
Avec des ± quasi nuls (p.ex. ±1e-9), le fit « converge » en 3-4 évaluations
**sans rien faire** (critère de convergence sur le pas atteint d'office).
Le WSSR ne baisse pas : fit apparemment mort.

**Règle pratique** : une fenêtre ± doit être large devant la précision visée,
petite devant l'écart entre pics. Pour un centre : ± ≥ ~1/10 du FWHM attendu.
Pour figer complètement un paramètre, utiliser le **cadenas** (lock), pas un
± minuscule — le cadenas retire le paramètre du fit proprement.

### 3. Paramètre « collé » à une borne à la fin du fit
Si un paramètre finit exactement sur sa borne (p.ex. centre = 255.1 avec
fenêtre [254.9 : 255.1]), c'est que le minimum « voulu » par les données est
à l'extérieur. Le fit a convergé, mais :
- le résultat est dicté par la contrainte, pas par les données ;
- **l'incertitude de ce paramètre n'est plus fiable** (info errors).

**Règle** : après un fit, vérifier les paramètres qui affichent une valeur
égale à une borne → soit élargir la fenêtre, soit assumer la contrainte.

### 4. Pics de trop (hauteur poussée à 0)
Avec hauteurs contraintes ≥ 0, un pic sans réalité physique finit hauteur ≈ 0
(le fit converge, testé). C'est le signal qu'il faut supprimer ce pic : il ne
sert à rien et dégrade le conditionnement des autres paramètres.

### 5. Ce qui ne pose PAS de problème (testé)
- Beaucoup de contraintes *cohérentes* : 3 gaussiennes avec centres ±0.2,
  hauteurs ≥ 0 et FWHM bornés → convergence normale (30 évaluations).
- Valeur initiale posée exactement sur une borne → OK.
- Hauteurs ≥ 0 par défaut → aucun impact sur un fit sain (résultats
  identiques à l'optimiseur d'origine sur fit bien initialisé, vérifié
  numériquement).

## Protocole conseillé pour converger

1. **Délimiter la zone active** (clic droit / mode Range) : seulement la
   région des pics à fitter, avec un peu de fond de part et d'autre.
2. **Soustraire le fond d'abord** (mode Background) si le fond n'est pas
   plat : un fond résiduel force les gaussiennes à s'élargir.
3. **Fit libre d'abord** : placer les gaussiennes (initialisation proche du
   vrai pic : centre à ±1 FWHM, hauteur au bon ordre de grandeur), fitter
   SANS contraintes de centre. → C'est le résultat de référence.
4. **Contraindre ensuite, progressivement** : ajouter le ± sur les centres
   qui doivent être physiquement fixés, refitter, et vérifier à chaque étape
   que le WSSR ne remonte pas de façon injustifiée.
5. **Une contrainte à la fois** quand ça coince : si le fit se bloque après
   l'ajout d'une contrainte, c'est elle la coupable — l'élargir ou la retirer.
6. **Vérifier les bornes actives** à la fin (§3) : un paramètre collé à sa
   borne = contrainte qui « travaille ».
7. **Supprimer les pics à hauteur ≈ 0** (§4) et refitter.
8. En cas de blocage inexpliqué : `Fit → Method`, essayer
   **Nelder-Mead Simplex** quelques itérations pour se dégager d'un mauvais
   point de départ, puis revenir à mpfit pour la précision finale.
   (Attention : Lev-Mar « own » et Nelder-Mead **ignorent les fenêtres ±** ;
   seul mpfit les respecte. Revenir à mpfit pour le résultat final.)

## Résumé en une ligne
Fit libre d'abord, contraintes ensuite et une par une, fenêtres ± généreuses,
cadenas pour figer, et se méfier d'un paramètre qui finit sur sa borne.
