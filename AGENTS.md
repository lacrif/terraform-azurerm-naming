# Guide pour les agents

## Objectif du dépôt

Ce dépôt contient un module Terraform autonome qui produit des conventions de
nommage pour les ressources Azure. Il ne crée aucune ressource Azure et ne
requiert ni backend Terraform ni authentification Azure.

## Organisation

- `main.tf` contient les règles de nommage et les ressources `random_string`.
- `variables.tf` expose les entrées du module.
- `outputs.tf` expose les noms calculés par type de ressource.
- `examples/main.tf` fournit des exemples d'utilisation locale du module ;
  son contenu est aussi injecté tel quel dans le README (section `Examples`
  générée par `terraform-docs`).
- `README.md` contient la documentation utilisateur et les exemples de
  consommation via le Terraform Module Registry GitLab. Les sections entre
  `<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->` et
  `<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->` (Requirements, Providers,
  Modules, Resources, Inputs, Outputs, Examples) sont générées par
  `terraform-docs` à partir de `main.tf`/`variables.tf`/`outputs.tf` et du
  contenu de `examples/main.tf` : ne jamais les éditer à la main, régénérer
  avec `terraform-docs -c .terraform-docs.yml .`.
- `.terraform-docs.yml` configure le format, le contenu (`content`, avec la
  section `Examples` embarquant `examples/main.tf` via `include`) et les
  marqueurs d'injection utilisés par `terraform-docs`.
- `.gitlab-ci.yml` définit les contrôles exécutés en CI (stage `quality` :
  formatage, `terraform validate`, vérification de la doc via
  `terraform-docs --output-check`) ainsi que la publication du module dans
  le Terraform Module Registry intégré du projet GitLab, déclenchée à chaque
  tag (stage `publish`, job `publish-module`).

## Règles de modification

- Préserver la compatibilité des entrées et sorties existantes, sauf demande
  explicite de changement incompatible.
- Pour ajouter ou modifier une convention de nommage, tenir `main.tf` et
  `outputs.tf` synchronisés, puis régénérer `README.md` avec `terraform-docs`
  (voir `## Validation`).
- Respecter les limites, caractères autorisés, portée d'unicité et slug propres
  à chaque ressource Azure.
- Le module est publié dans le Terraform Module Registry intégré de ce
  projet GitLab (nom `azure`, système `naming`) : conserver la cohérence
  entre `TERRAFORM_MODULE_NAME`/`TERRAFORM_MODULE_SYSTEM` dans
  `.gitlab-ci.yml` et les exemples de source (`gitlab.tech.orange/
  m2c-azure-falco/azure/naming`) documentés dans `README.md`.
- Toute publication d'une nouvelle version se fait exclusivement via un tag
  Git conforme au versioning sémantique (ex. `0.1.4`), qui déclenche le job
  `publish-module`. Ne pas publier de version manuellement hors CI.
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

Pour régénérer et vérifier la documentation (`terraform-docs` doit être
installé) :

```sh
terraform-docs -c .terraform-docs.yml .
terraform-docs -c .terraform-docs.yml --output-check .
```

La CI exécute le formatage, `terraform validate` avec Terraform 1.9, ainsi
que la vérification de la documentation avec `terraform-docs`.
