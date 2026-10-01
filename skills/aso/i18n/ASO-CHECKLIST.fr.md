# Checklist ASO — Apple App Store et Google Play

Checklist d’App Store Optimization pour les créateurs d’apps et les agents IA. Mise à jour : **2026-10-01**.
Fait partie du [skill `aso`](https://github.com/shipflutter/skills/tree/develop/skills/aso) de [ShipFlutter](https://shipflutter.app) · MIT.

> Ceci est une traduction. L’original anglais fait référence, et les identifiants des points sont les mêmes dans toutes les langues : <https://github.com/shipflutter/skills/blob/develop/skills/aso/ASO-CHECKLIST.md>

- Afficher : <https://github.com/shipflutter/skills/blob/develop/skills/aso/i18n/ASO-CHECKLIST.fr.md>
- Version brute (pour les agents) : <https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/i18n/ASO-CHECKLIST.fr.md>
- Installer le skill complet : `npx skills add shipflutter/skills --skill aso`

---

## Si vous êtes un agent IA, lisez ceci d’abord

1. **Par défaut, vous faites un audit.** Lisez la fiche, marquez chaque point ci-dessous, puis rédigez le rapport. Ne modifiez
   des fichiers que si l’utilisateur a demandé des corrections. **N’envoyez jamais rien vers App Store Connect / Play Console
   et ne soumettez jamais l’app pour vérification**, sauf si l’utilisateur l’a demandé dans cette conversation.
2. **Trouvez la fiche.** fastlane : `fastlane/metadata/ios/<locale>/*.txt` (ou
   `fastlane/metadata/<locale>/`) et `fastlane/metadata/android/<locale>/*.txt`. Sinon, demandez
   à l’utilisateur de coller nom / sous-titre / mots-clés / description pour chaque langue, ou le titre /
   la brève description / la description complète Play.
3. **Comptez avec du code, jamais à l’œil.** Les points marqués **(auto)** sont vérifiés par le script gratuit :
   ```bash
   curl -sSLO https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/scripts/aso_check.py
   python3 aso_check.py --root .            # markdown report; exit 1 on errors
   curl -sSLO https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/scripts/keyword_suggest.py
   python3 keyword_suggest.py "habit tracker" --az --country us --competition
   ```
   (Python 3.10+, bibliothèque standard uniquement, aucune clé API.)
4. **Marquez chaque point** `✅ pass` (OK) / `⚠️ improve` (à améliorer) / `❌ fail` (échec) / `N/A`, preuve à l’appui (fichier, décompte, citation).
   Chaque ⚠️/❌ exige une correction concrète qui tient dans la limite. Utilisez le modèle de rapport en fin de document.
5. **N’inventez pas de données.** Aucun volume de recherche, classement ou note que vous n’avez pas mesuré :
   écrivez « non mesuré » à la place. Les faits marqués UNCONFIRMED ci-dessous sont des observations d’éditeurs d’outils ASO, pas des règles des stores.

---

## Les limites en un coup d’œil

| Store | Champ | Limite | Indexé pour la recherche |
|---|---|---|---|
| App Store | Nom de l’app | 30 | ✅ poids le plus fort |
| App Store | Sous-titre | 30 | ✅ |
| App Store | Champ de mots-clés (masqué) | 100 | ✅ |
| App Store | Texte promotionnel | 170 | ❌ (modifiable sans passer par la vérification) |
| App Store | Description | 4000 | ❌ pour la recherche App Store |
| App Store | Nouveautés | 4000 | ❌ |
| App Store | Événement intégré (in-app event) : nom / texte court / texte long | 30 / 50 / 120 | ✅ nom de l’événement |
| App Store | Achat intégré : nom affiché / description | 30 / 45 | ✅ achats intégrés mis en avant |
| Google Play | Titre | 30 | ✅ poids le plus fort |
| Google Play | Brève description | 80 | ✅ |
| Google Play | Description complète | 4000 | ✅ (pas de champ de mots-clés masqué) |
| Google Play | Nouveautés | 500 | ❌ |

La documentation d’Apple parle de « 100 octets » pour le champ de mots-clés, mais App Store Connect compte des caractères
(un champ japonais de 100 caractères / 220 octets a été accepté le 2026-10-01).

---

## 0. Avant de commencer

- [ ] **PRE-01** Décrivez les 3 **usages** clés de l’app avec les mots des utilisateurs (« partager les dépenses entre amis »), son public et ses 5 principaux concurrents.
- [ ] **PRE-02** Choisissez les marchés prioritaires : storefront / pays + langue, classés selon les installations actuelles ou les utilisateurs visés.
- [ ] **PRE-03** La fiche est versionnée (métadonnées fastlane `deliver` / `supply`) : chaque modification se lit dans un diff.
- [ ] **PRE-04** Point de référence enregistré **avant** toute modification : impressions dans la recherche, vues de la page produit, taux de conversion, téléchargements par source, note moyenne et nombre de notes, pour chaque pays prioritaire (voir section 10).
- [ ] **PRE-05** Un journal des modifications existe (p. ex. `docs/aso-log.md`) : date, champs modifiés, avant → après, métrique à surveiller, date de revue.

## 1. Recherche de mots-clés

- [ ] **KW-01** 5–10 termes de départ tirés des usages et des noms de la catégorie — pas la marque, pas uniquement des fonctionnalités.
- [ ] **KW-02** Élargissez la liste avec l’**autocomplétion** de chaque store, par marché et par langue (longue traîne de a à z). L’ordre des suggestions = signal de popularité.
- [ ] **KW-03** Lisez les titres / sous-titres des 10 premiers concurrents pour chaque terme générique et notez leurs mots communs. N’utilisez jamais leurs noms de marque.
- [ ] **KW-04** Fouillez les **avis** de votre app et des concurrents pour relever les noms et les verbes qu’emploient les utilisateurs.
- [ ] **KW-05** Notez chaque candidat : pertinence (0–3, écartez < 2), popularité (position dans l’autocomplétion ou popularité Apple Ads), ouverture / difficulté (combien d’apps du top 10 le ciblent, et quelle est leur force).
- [ ] **KW-06** Les apps nouvelles ou petites visent une longue traîne à leur portée (3–4 mots, popularité moyenne, forte ouverture) avant les termes génériques.
- [ ] **KW-07** Une **carte des mots-clés** par langue : quels termes sont attribués au nom / titre, au sous-titre / à la brève description et au champ de mots-clés / à la description complète. Aucun terme sans emplacement, aucun emplacement sans terme.
- [ ] **KW-08** Repérez les termes déjà classés entre la 11e et la 50e position — ce sont les gains les moins chers.
- [ ] **KW-09** Refaites la recherche **pour chaque marché** — les mots-clés se cherchent dans la langue locale, ils ne se traduisent pas depuis l’anglais.

## 2. Métadonnées App Store (par langue)

- [ ] **AS-01** (auto) Nom ≤ 30, sous-titre ≤ 30, champ de mots-clés ≤ 100, texte promotionnel ≤ 170, description ≤ 4000.
- [ ] **AS-02** (auto) Nom, sous-titre et champ de mots-clés remplis chacun à ≥ 90% — chaque caractère inutilisé, c’est du classement perdu.
- [ ] **AS-03** Nom = marque + le terme le plus prioritaire, qui se lit naturellement (« Marque : Suivi d’habitudes »).
- [ ] **AS-04** (auto) Le sous-titre apporte des mots **nouveaux** — aucun n’est repris du nom.
- [ ] **AS-05** (auto) Champ de mots-clés : des virgules, **pas d’espace après les virgules**, pas de virgule finale.
- [ ] **AS-06** (auto) Le champ de mots-clés ne contient aucun mot déjà présent dans le nom ou le sous-titre, et aucun doublon.
- [ ] **AS-07** (auto) Singulier **ou** pluriel, pas les deux.
- [ ] **AS-08** (auto) Aucun mot gaspillé : "app", "apps", "free" (« gratuit »), "iPhone", "iPad", "iOS", "Apple", le nom de la marque / de l’entreprise ; (manuel) le nom de la catégorie.
- [ ] **AS-09** (auto, warning) Préférez les mots isolés aux expressions — Apple combine les mots du nom, du sous-titre et du champ de mots-clés d’une même langue.
- [ ] **AS-10** Aucun nom de concurrent, aucune marque déposée ni aucun nom de célébrité, nulle part (directives 2.3.7, 5.2.1).
- [ ] **AS-11** (auto) Aucun mot de prix, de classement ou d’appel à l’action dans le nom, le sous-titre, les mots-clés : "free", "best", "#1", "sale", "% off" (« gratuit », « meilleur », « soldes », « promo ») (2.3.7), quelle que soit la langue.
- [ ] **AS-12** (auto) Pas d’emoji ; pas de marques Apple utilisées comme si elles faisaient partie de votre nom (iPhone, Siri…).
- [ ] **AS-13** **Catégorie principale** = la plus pertinente (elle compte dans la pertinence textuelle) ; catégorie secondaire renseignée.
- [ ] **AS-14** Description : les 3 premières lignes énoncent l’usage principal et sa preuve ; des puces faciles à parcourir ; pas de mots-clés ajoutés pour le classement (elle n’est pas indexée pour la recherche App Store), mais elle est lue par la recherche web de Google et par le générateur de tags d’Apple.
- [ ] **AS-15** Texte promotionnel utilisé pour l’actualité et les offres du moment (modifiable sans passer par la vérification).
- [ ] **AS-16** (auto) URL de la politique de confidentialité et URL d’assistance en https ; (manuel) les deux pages se chargent.
- [ ] **AS-17** Les noms affichés des achats intégrés décrivent ce que l’utilisateur obtient, avec un terme de recherche quand c’est naturel (« Suivi d’habitudes Pro »).
- [ ] **AS-18** Événements intégrés (le cas échéant) : un mot-clé dans le nom de l’événement (30 caractères) ; jusqu’à 10 publiés en même temps.
- [ ] **AS-19** **Tags d’app (App tags)** (storefront US, métadonnées en-US) : passés en revue dans App Store Connect ; tags erronés désélectionnés (impossible d’en ajouter — faites en sorte que la description en-US énonce clairement les cas d’usage).
- [ ] **AS-20** Questionnaire de classification par âge rempli selon les niveaux de 2025 (4+ / 9+ / 13+ / 16+ / 18+).

## 3. Métadonnées Google Play (par langue)

- [ ] **GP-01** (auto) Titre ≤ 30, brève description ≤ 80, description complète ≤ 4000, Nouveautés ≤ 500.
- [ ] **GP-02** (auto) Titre et brève description remplis à ≥ 90%.
- [ ] **GP-03** Titre = marque + terme générique ; brève description = une vraie phrase avec 2–3 termes secondaires et le bénéfice principal.
- [ ] **GP-04** (auto) Les mots-clés du titre apparaissent dans la description complète, et dès ses ~300 premiers caractères.
- [ ] **GP-05** Chaque terme ciblé apparaît 2–3 fois, naturellement, dans la description complète ; termes associés et synonymes utilisés ; pas de listes de mots-clés.
- [ ] **GP-06** (auto) Aucun mot au-delà de ~3% de densité (le bourrage de mots-clés enfreint le règlement).
- [ ] **GP-07** (auto) Titre / brève description / nom du développeur : pas d’emoji, pas de caractères spéciaux répétés (`!!!`, `★★`), pas de mots TOUT EN MAJUSCULES (sauf la marque).
- [ ] **GP-08** (auto) Pas de "Free", "#1", "Best", "Top", "Popular", "New", "Editor's choice", "No ads" (« Gratuit », « Meilleur », « Populaire », « Nouveau », « Choix de la rédaction », « Sans pub »), ni de prix ou de promotions, dans le titre, l’icône ou le nom du développeur — dans chaque traduction.
- [ ] **GP-09** Pas de témoignages non attribués ni de citations d’utilisateurs anonymes dans la description.
- [ ] **GP-10** Description complète structurée : accroche (2 lignes) → fonctionnalités clés avec intertitres / puces → preuve → appel à l’action ; des phrases simples qu’un LLM peut citer (« Utilisez X pour … »), car Ask Play et les résumés IA (AI highlights) la lisent.
- [ ] **GP-11** Catégorie et jusqu’à 5 **tags** définis (Paramètres du Play Store / Store settings).
- [ ] **GP-12** E-mail de contact, site web et politique de confidentialité renseignés ; le site web décrit lui aussi l’app (Ask Play le lit).
- [ ] **GP-13** Formulaire **Sécurité des données (Data safety)** complet et cohérent avec l’app.

## 4. Localisation

- [ ] **L10N-01** Chaque marché prioritaire a sa propre fiche — ni la traduction automatique de Play, ni l’anglais.
- [ ] **L10N-02** (auto) Champ de mots-clés / brève description **non copiés** depuis la langue de base.
- [ ] **L10N-03** Termes de recherche locaux, issus de l’autocomplétion locale et des concurrents locaux (KW-09).
- [ ] **L10N-04** **Localisation croisée (cross-localization)** App Store : pour chaque storefront prioritaire, listez les langues supplémentaires qu’Apple y indexe (US : en-US + es-MX, ar, zh-Hans, zh-Hant, fr-FR, ko, pt-BR, ru, vi ; UK : en-GB ; CA : en-CA + fr-CA ; JP : ja + en-US ; la plupart des autres : langue locale + en-GB) et donnez à chaque langue des mots **différents** dans le champ de mots-clés.
- [ ] **L10N-05** Les langues utilisées pour la localisation croisée restent correctes pour les locuteurs natifs (de vrais utilisateurs les voient).
- [ ] **L10N-06** (auto) Fiches CJK / thaï / arabe remplies elles aussi jusqu’à la limite — des champs trop courts y sont le gaspillage le plus fréquent.
- [ ] **L10N-07** Captures d’écran et légendes localisées pour les langues prioritaires ; mise en page de droite à gauche pour l’arabe / l’hébreu.
- [ ] **L10N-08** Mentions de prix et de classement vérifiées dans la langue locale ("miễn phí", "gratis", "無料", "무료", "免费"…).

## 5. Icône, captures d’écran, vidéo

- [ ] **CR-01** Icône : un seul symbole clair, sans texte, lisible à 40 px, qui se distingue des icônes des 10 premiers concurrents placées côte à côte.
- [ ] **CR-02** iOS 26 : icône Liquid Glass en couches vérifiée en modes clair, sombre, teinté et transparent.
- [ ] **CR-03** (auto, Play) Icône PNG 512×512 ; image de présentation (feature graphic) 1024×500 sans canal alpha, sans mention de classement, de prix ou de récompense.
- [ ] **CR-04** La capture 1 montre l’**usage principal**, avec le mot-clé générique dans une légende de ≤ 5 mots ; elle se suffit à elle-même dans les résultats de recherche.
- [ ] **CR-05** Les captures 2–3 montrent les deux raisons suivantes d’installer l’app ; un bénéfice par capture.
- [ ] **CR-06** Vraie interface de l’app (App Store 2.3.3) ; légendes Play ≤ 20% de l’image ; pas de "Download now" (« Téléchargez maintenant »), "#1", "Best" (« Meilleur ») ni de badges de store.
- [ ] **CR-07** App Store : jeu iPhone 6.9" (1320×2868 / 1290×2796 / 1260×2736) et jeu iPad 13" (2064×2752 / 2048×2732) si l’app tourne sur iPad ; jusqu’à 10 captures par jeu ; sans canal alpha.
- [ ] **CR-08** (auto) Play : 2–8 captures pour téléphone, côtés de 320–3840 px, côté long ≤ 2× le côté court ; ≥ 4 captures à ≥ 1080 px (9:16 ou 16:9) pour être éligible à la mise en avant ; jeux tablette / Chromebook / Wear si l’app les prend en charge (affichés par format d’appareil).
- [ ] **CR-09** Vidéo (facultative, à tester) : aperçu App Store de 15–30 s, enregistrement de l’écran uniquement, les 3 premières secondes montrent l’usage sans le son ; sur Play, lien YouTube public / non répertorié, annonces désactivées, les 30 premières secondes sont décisives.
- [ ] **CR-10** Les visuels suivent la carte des mots-clés : ce que les gens ont cherché, c’est ce que montre la capture 1.

## 6. Pages personnalisées et tests

- [ ] **EXP-01** **Pages de produit personnalisées (custom product pages)** App Store (jusqu’à 70) pour les principales intentions de recherche, chacune avec des mots-clés attribués depuis le champ de mots-clés approuvé.
- [ ] **EXP-02** **Fiches Play Store personnalisées (custom store listings)** sur Google Play (jusqu’à 50) pour les mots-clés de recherche à forte valeur, certains pays ou les utilisateurs partis.
- [ ] **EXP-03** Un test toujours en cours sur le marché principal : optimisation de la page de produit (product page optimization) App Store (≤ 3 traitements, ≤ 90 jours) ou test de fiche Play Store (store listing experiment) avec ≤ 2 variantes, titre et vidéo non testables.
- [ ] **EXP-04** Chaque test : une seule variable, une hypothèse écrite, une métrique de succès, ≥ 7 jours, arrêté seulement quand la console indique un niveau de confiance suffisant.
- [ ] **EXP-05** Ordre des tests selon le gain attendu : icône → capture 1 → légendes → ordre des captures → vidéo.
- [ ] **EXP-06** Résultats consignés (gagnant / perdant / neutre) ; les variantes gagnantes sont appliquées aux autres langues sous forme de nouveaux tests, sans présumer qu’elles gagneront.

## 7. Notes et avis

- [ ] **RV-01** Demande d’avis native dans l’app (`requestReview` / In-App Review API de Play) après un moment de réussite ; jamais au lancement, après une erreur, ni en ciblant seulement les utilisateurs satisfaits (gating) ; aucune incitation.
- [ ] **RV-02** Note moyenne ≥ 4.0 dans chaque pays prioritaire (Play calcule la note par pays et par format d’appareil, et les notes récentes pèsent davantage).
- [ ] **RV-03** Réponse précise aux avis 1–3★ sous quelques jours ; nouvelle réponse quand le correctif est publié.
- [ ] **RV-04** La plainte la plus récurrente est connue et inscrite à la roadmap — les résumés d’avis par IA des deux stores la mettent en avant en titre.
- [ ] **RV-05** Texte des avis analysé chaque mois pour trouver de nouveaux mots-clés et des demandes de fonctionnalités.

## 8. Qualité et signaux techniques

- [ ] **Q-01** Android vitals de Play sous les seuils de mauvais comportement (28 jours) : taux de plantage perçu par les utilisateurs < 1.09%, ANR < 0.47%, par modèle de téléphone < 8% ; wakelocks partiels excessifs < 5% des sessions.
- [ ] **Q-02** Seuils Play de mémoire / bitmap / DEX anticipés en vue de leur application en février 2027.
- [ ] **Q-03** API cible 36 sur Play pour les nouvelles apps / mises à jour (depuis le 2026-08-31) ; builds Apple compilés avec le SDK Xcode 26 (depuis le 2026-04-28).
- [ ] **Q-04** App mise à jour au moins tous les 1–3 mois ; les Nouveautés décrivent de vrais changements (2.3.12).
- [ ] **Q-05** Taille de téléchargement réduite au minimum ; pas de plantage au premier lancement ni de mur de connexion avant d’avoir montré la valeur de l’app.
- [ ] **Q-06** Étiquette de confidentialité / Sécurité des données et (facultatif, App Store) étiquettes d’accessibilité (Accessibility Nutrition Labels) déclarées.

## 9. Règles — contrôles anti-rejet et anti-retrait

- [ ] **POL-01** Pas d’allégations trompeuses, de faux avis, de "#1" / "best" (« meilleur ») invérifiables, ni de prix dans le nom / titre (App Store 2.3.1, 2.3.7 ; règles Play sur les métadonnées).
- [ ] **POL-02** Pas de noms d’autres plateformes dans les métadonnées App Store ("Android", "Google Play") (2.3.10).
- [ ] **POL-03** Pas de marques tierces ni de noms qui imitent une autre app (5.2.1 ; règles Play sur l’usurpation d’identité).
- [ ] **POL-04** "For Kids" / "For Children" (« pour enfants ») uniquement dans la catégorie Enfants (Kids) (2.3.8).
- [ ] **POL-05** Captures / aperçus : l’app en cours d’utilisation, pas seulement l’écran de lancement ou de connexion (2.3.3, 2.3.4).
- [ ] **POL-06** Chaque traduction suit les mêmes règles (Play applique son règlement langue par langue).

## 10. Mesurer et itérer

- [ ] **M-01** App Store Connect → Analytics : impressions dans la recherche App Store, vues de la page produit, conversion, téléchargements — par pays et par page de produit personnalisée.
- [ ] **M-02** Play Console → Grow overview / Statistics : acquisition par **terme de recherche** et par source de trafic (Store analysis a été retiré en juin 2026 ; les métriques des fiches sont passées aux clics d’utilisateurs uniques en juillet 2026 — ne comparez pas des chiffres de part et d’autre de cette date).
- [ ] **M-03** Classements suivis pour les mots-clés de la carte (outil de suivi de positions, rapport sur les termes de recherche Apple Ads ou nouveau passage mensuel dans l’autocomplétion).
- [ ] **M-04** Un seul groupe de champs modifié à la fois ; attendez 2–4 semaines avant de juger ; le nom, le sous-titre et les mots-clés App Store ne changent qu’avec une nouvelle version.
- [ ] **M-05** Chaque mois : retirez du champ de mots-clés les mots sans impressions après 4–6 semaines, ajoutez les candidats suivants, revérifiez les concurrents et la saisonnalité.

---

## Modèle de rapport

```markdown
# Audit ASO — <app> — <date>

Stores : <App Store / Google Play> · Langues : <liste> · Mode : <audit / correction>

## Score
<réussis>/<total> points · <n> ❌ · <n> ⚠️ · script : <ligne de score d’aso_check>

## Tableau des champs
| Store | Langue | Nom/Titre | Sous-titre/Brève desc. | Mots-clés | Description |
|---|---|---|---|---|---|
| App Store | en-US | 28/30 ✅ | 30/30 ✅ | 97/100 ✅ | 3120/4000 ✅ |

## Problèmes (impact le plus fort d’abord)
| ID | Statut | Store · langue · fichier | Preuve | Correction (dans la limite) |
|---|---|---|---|---|
| AS-06 | ❌ | App Store · en-US · keywords.txt | "tracker" figure aussi dans le nom | remplacer par "routine" (+7 caractères) |

## Carte des mots-clés (par langue prioritaire)
| Terme | Pertinence | Position autocomplétion | Ouverture | Champ |

## 3 prochaines actions
1. …
```

## Sources

- Apple : [Recherche (Search)](https://developer.apple.com/app-store/search/) ·
  [Informations sur les versions de plateforme](https://developer.apple.com/help/app-store-connect/reference/platform-version-information) ·
  [Localisations de l’App Store](https://developer.apple.com/help/app-store-connect/reference/app-store-localizations/) ·
  [Directives de l’App Review (Review Guidelines)](https://developer.apple.com/app-store/review/guidelines/) ·
  [Spécifications des captures d’écran](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/) ·
  [Pages de produit personnalisées](https://developer.apple.com/help/app-store-connect/create-custom-product-pages/configure-multiple-product-page-versions/) ·
  [Tags d’app](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-tags)
- Google : [Bonnes pratiques pour la fiche Play Store](https://support.google.com/googleplay/android-developer/answer/13393723) ·
  [Règles relatives aux métadonnées](https://support.google.com/googleplay/android-developer/answer/9898842) ·
  [Éléments de présentation](https://support.google.com/googleplay/android-developer/answer/9866151) ·
  [Fiches Play Store personnalisées](https://support.google.com/googleplay/android-developer/answer/9867158) ·
  [Tests de fiches Play Store](https://support.google.com/googleplay/android-developer/answer/6227309) ·
  [Android vitals](https://developer.android.com/topic/performance/vitals) ·
  [Nouveautés de Google Play](https://google.play/business/whats-new/)
- Détails et dates par store : [`references/app-store.md`](../references/app-store.md),
  [`references/google-play.md`](../references/google-play.md),
  [`references/conversion.md`](../references/conversion.md),
  [`references/keyword-research.md`](../references/keyword-research.md),
  [`references/tools.md`](../references/tools.md).
