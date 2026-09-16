# Tests du module de nommage, exécutés via `terraform test` (>= 1.6).
# Aucune ressource Azure n'est créée : seul le provider `random` est utilisé,
# donc ces tests tournent en local et en CI sans authentification Azure.

run "defaults_all_valid" {
  # Aucune variable : sans prefix/suffix, `name` peut être trop court pour
  # certains types (il vaut alors juste le slug, ex. "as"), ce qui est
  # attendu : c'est précisément le rôle de `name_unique`, qui complète
  # toujours avec la partie aléatoire. On vérifie donc que `local.validation`
  # (regex + longueur mini, calculé pour chacun des ~200 types de ressource)
  # est vrai partout pour `valid_name_unique`.
  assert {
    condition     = alltrue([for k, v in output.validation : v.valid_name_unique])
    error_message = "Au moins un type de ressource produit un `name_unique` invalide avec les valeurs par défaut."
  }
}

run "prefix_and_suffix_all_valid" {
  variables {
    prefix = ["contoso"]
    suffix = ["prod"]
  }

  assert {
    condition     = alltrue([for k, v in output.validation : v.valid_name])
    error_message = "Au moins un type de ressource produit un `name` invalide avec prefix/suffix renseignés."
  }

  assert {
    condition     = alltrue([for k, v in output.validation : v.valid_name_unique])
    error_message = "Au moins un type de ressource produit un `name_unique` invalide avec prefix/suffix renseignés."
  }

  assert {
    condition     = output.storage_account.name == "contosostprod"
    error_message = "Le nom du storage_account ne concatène pas prefix/slug/suffix comme attendu (sans tiret, en minuscules)."
  }
}

run "long_inputs_respect_max_length" {
  # Prefix/suffix volontairement bien plus longs que n'importe quel max_length,
  # pour vérifier que la troncature `substr(..., 0, max_length)` est bien
  # appliquée et ne casse pas le regex, quel que soit le style du slug
  # (avec ou sans tirets).
  variables {
    prefix = ["aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
    suffix = ["bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"]
  }

  assert {
    condition     = alltrue([for k, v in output.validation : v.valid_name])
    error_message = "Au moins un type de ressource produit un `name` invalide avec des entrées très longues."
  }

  assert {
    condition     = alltrue([for k, v in output.validation : v.valid_name_unique])
    error_message = "Au moins un type de ressource produit un `name_unique` invalide avec des entrées très longues."
  }

  assert {
    condition     = length(output.storage_account.name) == output.storage_account.max_length
    error_message = "storage_account.name dépasse ou n'atteint pas max_length après troncature."
  }

  assert {
    condition     = length(output.container_registry.name) == output.container_registry.max_length
    error_message = "container_registry.name dépasse ou n'atteint pas max_length après troncature."
  }

  assert {
    condition     = length(output.key_vault.name) == output.key_vault.max_length
    error_message = "key_vault.name dépasse ou n'atteint pas max_length après troncature."
  }

  assert {
    condition     = length(output.api_management.name) == output.api_management.max_length
    error_message = "api_management.name dépasse ou n'atteint pas max_length après troncature."
  }
}

run "unique_seed_is_deterministic" {
  variables {
    unique-seed   = "myseed"
    unique-length = 6
  }

  assert {
    condition     = output.unique-seed == "myseed"
    error_message = "L'output unique-seed devrait renvoyer telle quelle la seed explicitement fournie."
  }

  assert {
    condition     = output.storage_account.name_unique == "stmyseed"
    error_message = "name_unique devrait être déterministe (slug + seed complète) quand unique-seed est fourni."
  }
}

run "unique_length_truncates_seed" {
  variables {
    unique-seed   = "abcdefghijklmnop"
    unique-length = 10
  }

  assert {
    condition     = output.storage_account.name_unique == "stabcdefghij"
    error_message = "La partie aléatoire devrait être tronquée à unique-length caractères de la seed fournie."
  }
}

run "unique_include_numbers_false_has_no_digits" {
  variables {
    unique-include-numbers = false
  }

  assert {
    condition     = length(regexall("[0-9]", output.unique-seed)) == 0
    error_message = "unique-include-numbers = false ne devrait produire aucun chiffre dans la seed générée."
  }
}
