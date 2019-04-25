# Docker devtools

Ce dépôt contient deux conteneurs [Docker](https://www.docker.com/) utiles à la réalisation de vos projets Dockerisés.
On trouve le reverse proxy HTTP nommé [Traefik](https://docs.traefik.io/) et une interface de gestion des hôtes Docker, [Portainer](https://portainer.io/).

# Démarrage rapide

- cloner le projet `git clone && cd docker-devtools`
- installer dnsmasq `sudo apt install dnsmasq`
- créer le fichier /etc/dnsmasq.d/local.zephyr-ci.top incluant la ligne `echo 'address=/local.zephyr-ci.top/127.0.0.1' | sudo tee /etc/dnsmasq.d/local.zephyr-ci.top`
- ajouter 127.0.0.1 à la liste de vos DNS utilisés
- créer le réseau traefik : `docker network create traefik`
- make up

## Dépendances

- [Docker 18.06.1](https://docs.docker.com/install/)
- [Docker Compose 1.22.0 (v3.5)](https://docs.docker.com/compose/)

## Description

| Service | Name | Frontend (`TRAEFIK_DOMAIN=traefik.docker`) | Description |
|:--------|:-----|:---------|:------------|
| [Traefik](https://docs.traefik.io/) | traefik | http://traefik-dashboard.traefik.docker/ | Traefik est un service de mandataire inverse (reverse-proxy) dynamique réalisé en Go par le français Emile Vauge en 2015. |
| [Portainer](https://portainer.io/) | portainer | http://portainer.traefik.docker/ | Portainer est une interface utilisateur de gestion qui vous permet de gérer facilement vos hôtes Docker et vos [Swarm](https://docs.docker.com/get-started/part4/) clusters. |

# Utilisation et explications

## Installation manuelle

Tout d'abord, il faut copier le fichier `env.dist`
```bash
cp .env.dist .env
cp docker-compose.override.yml.dist docker-compose.override.yml
```

Ensuite il reste à construire et lancer l'ensembles des services.
```bash
docker-compose build
docker-compose up -d --build
```

## Traefik
### Utilisation

[Traefik](https://docs.traefik.io/) est un service de mandataire inverse (reverse-proxy) dynamique. Il peut être couplé avec Docker afin d'obtenir des noms de domaine pour vos interfaces web.
Pour ce faire, il faut lancer le service Traefik et ajoutez les lignes suivantes au conteneur visé.
```bash
docker-compose up -d --build traefik
```
```yaml
networks:
    traefik:
        external: { name: traefik }
services:
    apache:
        labels:
            - "traefik.enable=true"
            - "traefik.port=80"
            - "traefik.backend=mon-projet"
            - "traefik.frontend.rule=Host:mon-projet.${TRAEFIK_DOMAIN}"
        networks:
            - traefik
```

Plusieurs variables d'environnements sont nécessaires au bon fonctionnement du système. 
On trouve tout d'abord la variable `TRAEFIK_DOMAIN` qui comme son nom l'indique définit le domaine des applications sous Traefik.
Zephyr possède un nom de domaine pour le développement (zephyr-ci.top), à l'installation du projet c'est ce dernier qui sera utilisé avec Let's Encrypt. 
Si vous ne voulez pas changer, il suffit de laisser `TRAEFIK_DOMAIN=local.zephyr-ci.top` dans le fichier `.env`

Deux variables supplémentaires sont à disposition, `TRAEFIK_DEBUG` et `TRAEFIK_LOG_LEVEL` qui respectivement permettent d'activer ou non le debug et d'en préciser le niveau (INFO, DEBUG ou ERROR)

Enfin, il reste la variable `TRAEFIK_GANDIV5_API_KEY` qui permet de générer les certificats Let's Encrypt. Pour la valeur de cette dernière, il faut faire la demande auprès d'un responsable Zephyr.

### Utilisateurs Linux

Généralement, les distributions linux ont toujours un résolveur dns 

Pour la distribution debian:

- créer le fichier /etc/dnsmasq.d/local.zephyr-ci.top incluant la ligne `address=/local.zephyr-ci.top/127.0.0.1`
- dans le fichier /etc/NetworkManager/NetworkManager.conf ajouter `dns=dnsmasq` dans la partie `[main]`

Pour les distributions ubuntu, il existe un service dnsmasq qui gère la résolution par exemple). 
Il faut donc réaliser quelques actions avant de lancer traefik:
* Ajoutez la ligne suivante à votre fichier `/etc/NetworkManager/dnsmasq.d/dnsmasq.conf`.
```
# /etc/NetworkManager/dnsmasq.d/dnsmasq.conf
address=/local.zephyr-ci.top/127.0.0.1
```


## Portainer
### Description

[Portainer](https://portainer.io/) est une interface de gestion des dockers installés sur la machine.
Elle vous permettra d'avoir une visualisation de l'ensemble de vos ressources Docker mais aussi de les manager.
