# ansible-raspi

Installation de nos Raspberry PI.

## Table of contents

<!-- toc -->

- [Vault](#vault)
  * [Chiffrer l'ensemble des fichiers](#chiffrer-lensemble-des-fichiers)
  * [Déchiffrer l'ensemble des fichiers](#dechiffrer-lensemble-des-fichiers)
- [Preparation de la SD Card](#preparation-de-la-sd-card)
- [TODO](#todo)

<!-- tocstop -->

## Vault

Afin de chiffrer / déchiffré les fichiers contenant des informations sensible, il faut :

```bash
echo "password" > .vault_password
```

### Chiffrer l'ensemble des fichiers

```bash
make encrypt
```

L'ensemble des fichiers *.vault.* seront chiffré avec le password.

### Déchiffrer l'ensemble des fichiers

```bash
make decrypt
```

L'ensemble des fichiers *.vault.* seront déchiffré avec le password pour être mofifiés.

> NB : Les hooks de pre-commit vérifier que le contenu de ces fichiers ne seront pas commité non chiffré

## Preparation de la SD Card

Cette première étape permet de mettre l'OS de base sur la SD Card de la raspberry pi.

Il faut renseigner le device sur lequel on souhaite faire la restauration.

```bash
make sd_card
```

> NB : L'écriture sur le device est réaliser en superuser.

## TODO

> Play init ajout authorized_keys root

> Configuration de l'orientation du LCD
> Role standard (vim, htop, etc...)
> Role Java + JavaFX
> Role GUI light
