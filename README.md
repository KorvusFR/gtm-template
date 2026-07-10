# Korvus - Google Tag Manager template

Korvus detecte les fuites financieres d'un site e-commerce (pixels morts,
erreurs de checkout, codes promo surutilises), calcule leur impact en euros par
heure, et alerte l'equipe avec une action corrective immediate.

Ce template expose deux tags dans un seul modele : l'initialisation du snippet
et l'evenement de transaction.

## Installation

Dans Google Tag Manager, ouvrir l'onglet **Templates**, cliquer sur **Search
Gallery** dans la section *Tag Templates*, chercher **Korvus** et ajouter le
template au conteneur.

### Tag 1 - Initialisation

| Champ | Valeur |
|---|---|
| Tag type | `Initialization (all pages)` |
| API key | la cle affichee dans les reglages du dashboard Korvus |
| Declencheur | All Pages |

Le tag charge `https://cdn.korvus.fr/v1/korvus.min.js` et expose la
configuration sur `window.__korvus`.

### Tag 2 - Evenement de transaction

| Champ | Valeur |
|---|---|
| Tag type | `Transaction event (order confirmation)` |
| Transaction value | variable Data Layer du montant de la commande |
| Currency | code ISO 4217, `EUR` par defaut |
| Declencheur | l'evenement de confirmation de commande |

Le tag pousse une entree sur `window.korvusLayer`. Cette file est
**independante de l'ordre de chargement** : si le tag se declenche avant que
`korvus.min.js` ait fini de charger, l'entree attend en memoire et le snippet
la consomme des qu'il demarre. Aucun sequencement de tags n'est necessaire.

Le montant accepte un nombre comme une chaine brute (`449`, `"449.00"`,
`"1 234,56"`) : la normalisation monetaire est faite cote serveur.

## Consentement

Le montant de la transaction est une donnee **soumise a consentement**. Korvus
la supprime cote navigateur, sans aucun appel reseau, lorsque le statut de
consentement du visiteur n'est pas `granted`. Le tag ne remonte donc jamais
100 % des conversions : il remonte 100 % des conversions consenties.

**Le tag Transaction peut se declencher sans condition.** Le gate de
consentement est applique par le snippet lui-meme, pas par le declencheur : il
n'est pas necessaire de conditionner le tag au Consent Mode de Google Tag
Manager. Le faire reste possible et sans effet de bord, c'est une defense
supplementaire, jamais un prerequis.

Le fait qu'une transaction ait eu lieu est capte separement, sans montant et
sans consentement, par le signal `purchase_observed` du snippet.

## Permissions demandees

| Permission | Portee | Raison |
|---|---|---|
| `inject_script` | `https://cdn.korvus.fr/v1/korvus.min.js` | charger le snippet |
| `access_globals` | `__korvus` (ecriture) | transmettre la cle API au snippet |
| `access_globals` | `korvusLayer` (lecture, ecriture) | file d'attente des transactions |

## Support

Ouvrir une issue sur ce depot, ou ecrire a support@korvus.fr.

## Licence

Apache License 2.0 - voir [LICENSE](LICENSE).
