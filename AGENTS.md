# Guide pour les agents

## Objectif du dépôt

Ce dépôt contient un module Terraform autonome qui produit des conventions de
nommage pour les ressources Azure. Il ne crée aucune ressource Azure et ne
requiert ni backend Terraform ni authentification Azure.

## Organisation

- `main.tf` contient les règles de nommage et les ressources `random_string`.
- `variables.tf` expose les entrées du module.
- `outputs.tf` expose les noms calculés par type de ressource.
- `examples/main.tf` fournit des exemples d'utilisation locale du module.
- `README.md` contient la documentation utilisateur et les exemples de
  consommation Git du fork.
- `.gitlab-ci.yml` définit les contrôles exécutés en CI.

## Règles de modification

- Préserver la compatibilité des entrées et sorties existantes, sauf demande
  explicite de changement incompatible.
- Pour ajouter ou modifier une convention de nommage, tenir `main.tf` et
  `outputs.tf` synchronisés, puis mettre à jour la documentation si nécessaire.
- Respecter les limites, caractères autorisés, portée d'unicité et slug propres
  à chaque ressource Azure.
- Ne pas réintroduire de dépendance au Terraform Registry pour ce module : les
  exemples de consommation utilisent la source Git du fork.
- Ne pas modifier `.terraform.lock.hcl` sans changement intentionnel de la
  contrainte de fournisseur ou réinitialisation explicitement demandée.

## Validation

Exécuter depuis la racine du dépôt :

```sh
terraform fmt -check -diff -recursive .
terraform init
terraform validate -no-color
```

Lorsque `tflint` est installé, exécuter également :

```sh
tflint --no-color
```

`make validate` regroupe ces validations. La CI exécute le formatage et
`terraform validate` avec Terraform 1.9.
