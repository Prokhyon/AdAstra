# Ad Astra

Outils numériques créés pour **Ad Astra**, un jeu de rôle grandeur nature inspiré de *Mars Express*, joué le 2 mars 2025.

## Le jeu

Les joueurs incarnent des détenus à bord d'un vaisseau-prison en route vers un pénitencier. Après un crash, ils peuvent explorer la planète au cours de petites expéditions. Ils y rencontrent des ennemis, récupèrent des matériaux et trouvent des **codes** dans des laboratoires. Ces codes doivent ensuite être analysés à bord du vaisseau pour obtenir des matériaux ou des objets.

Chaque personnage a un **état de santé** (empoisonné, irradié, blessé, inconscient…), qui peut aller jusqu'à la mort. Certains rôles et objets permettent de soigner, voire de ramener un personnage à la vie sous forme de « sauvegardé ».

Il existe quatre **origines** :

| Origine | Description |
| --- | --- |
| Humain·e·x | Humain sans modification |
| Augmenté·e·x | Humain équipé d'implants |
| Androïde | Être artificiel |
| Sauvegardé | Humain mort dont la conscience a été placée dans un androïde |

## Les applications

| App | Plateforme | Rôle |
| --- | --- | --- |
| **AdAstraVitals** | Mac relié à une TV | Écran de bord du vaisseau : constantes des personnages et transmissions |
| **AdAstraPad** | iPad | Console de l'organisation : pilote l'écran de bord et les lumières |
| **AdAstraTrial** | Mac avec deux moniteurs | Laboratoire du vaisseau : analyse des codes trouvés en expédition |

AdAstraVitals et AdAstraPad se trouvent dans le même projet Xcode (`AdAstraVitals/`) et partagent le modèle de données et le code réseau.

### AdAstraVitals — l'écran de bord

Affiché sur une TV dans le vaisseau, il présente une fiche pour chacun des 13 personnages :

- **portrait** en hologramme, nom et origine ;
- **rythme cardiaque** animé : calme, actif ou plat en cas de mort. Les humains et augmentés ont un tracé ECG, les androïdes et sauvegardés une onde sinusoïdale ;
- **état médical**, avec une icône.

En haut de l'écran, une **horloge de jeu** démarre à 14h00 et avance trois fois plus vite que le temps réel.

L'écran reçoit aussi les **transmissions** envoyées depuis l'iPad. Elles restent affichées jusqu'à ce que l'iPad les retire. Une transmission de type *Alerte* teinte l'écran en rouge et déclenche une sirène.

Une fenêtre secondaire, *Edit Players*, permet de modifier les personnages directement sur le Mac. Ces modifications restent locales : elles ne sont pas renvoyées à l'iPad et seront écrasées par sa prochaine mise à jour.

### AdAstraPad — la console de l'iPad

Tout le jeu se pilote depuis l'iPad, organisé en trois onglets :

- **Détenus** : choisir un personnage pour changer son état et son rythme cardiaque.
  - **Tuer** passe le personnage en *Décédé* avec un rythme plat.
  - **Revivre** le remet en état normal, au repos. Un humain ou un augmenté devient alors *Sauvegardé*.
- **Communications** : rédiger et envoyer des messages (*Alerte*, *Transmission*, *Information*), en préparer à l'avance et retirer celui qui est affiché.
- **Environnement** : régler, lancer ou mettre en pause l'horloge de jeu, déclencher ou couper l'alarme, et contrôler les lumières.

#### Bandes LED

Des bandes LED installées dans le décor sont pilotées par l'app **Raccourcis** d'iOS. AdAstraPad lance l'un de ces trois raccourcis, qui doivent exister sur l'iPad :

| Raccourci | Effet |
| --- | --- |
| `LED Spaceship` | Éclairage normal du vaisseau |
| `LED Alarme` | Clignotement rouge (alerte, alarme) |
| `LED Flash` | Flashs blancs rapides et intenses (problème technique) |

L'envoi d'une alerte lance automatiquement `LED Alarme`, et retirer le message affiché lance `LED Spaceship`.

### AdAstraTrial — le laboratoire

Deux participants s'installent face à face, chacun devant un moniteur. L'app ouvre une fenêtre par moniteur :

1. Le participant côté grille saisit le code trouvé en expédition. Chaque code n'est accepté qu'une seule fois.
2. Son partenaire voit apparaître un symbole extraterrestre et doit le **décrire** à voix haute.
3. Le participant côté grille doit le **retrouver** parmi une grille de symboles.
4. En cas de réussite, l'app affiche le texte déchiffré, à échanger auprès de l'organisation contre un matériau ou un objet. En cas d'échec, une seconde tentative est accordée.

Les symboles proviennent de plusieurs polices fantaisie incluses dans `AdAstraTrial/AdAstraTrial/Font/`. La liste des codes et leurs correspondances sont définies dans `ContentView.swift` et `ResultView.swift`.

## Communication entre le Mac et l'iPad

AdAstraPad et AdAstraVitals communiquent via **Multipeer Connectivity** (Wi-Fi ou Bluetooth, sans serveur). Les deux appareils se découvrent et se connectent automatiquement au lancement. L'iPad envoie trois types de données :

- la liste complète des personnages à chaque modification ;
- les messages à afficher ;
- des commandes simples : horloge, alarme, retrait du message.

La liste des personnages est définie dans `AdAstraVitals/MultipeerManager.swift`.

## Compiler et lancer

Ouvrir le projet voulu dans Xcode :

- `AdAstraVitals/AdAstraVitals.xcodeproj`
  - schéma **AdAstraVitals** : Mac, macOS 15 ou plus ;
  - schéma **AdAstraPad** : iPad, iPadOS 15.6 ou plus.
- `AdAstraTrial/AdAstraTrial.xcodeproj` : schéma **AdAstraTrial** pour Mac.

Toutes les apps s'affichent uniquement en mode sombre.

### Ressources non incluses

Certaines images et sons utilisés pendant le jeu sont protégés par le droit d'auteur et ne sont pas publiés dans ce dépôt. Les apps compilent sans eux, mais les emplacements correspondants restent vides. Pour les retrouver, il faut fournir ses propres fichiers aux emplacements suivants :

| Emplacement | Contenu |
| --- | --- |
| `AdAstraVitals/AdAstraVitals/Assets.xcassets/AdAstraPhotos/*.imageset/` | Portraits des personnages |
| `*/Assets.xcassets/galaxyMap.imageset/` (dans les deux apps) | Image de fond, une carte de galaxie |
| `AdAstraVitals/AdAstraVitals/ImperialAlarm.mp3` | Son de la sirène d'alerte |

Pour une image, la déposer dans le dossier `.imageset` voulu depuis Xcode. Pour le son, le nom du fichier doit être exactement `ImperialAlarm.mp3`.

## Structure

```
AdAstraVitals/
├── SharedCode.swift         Modèle partagé : personnages, états, origines, messages
├── MultipeerManager.swift   Connexion Mac ↔ iPad et liste des personnages
├── AdAstraVitals/           App Mac de l'écran de bord
└── AdAstraPad/              App iPad de contrôle
AdAstraTrial/                App Mac du laboratoire
```
