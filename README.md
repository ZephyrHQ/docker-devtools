# Docker devtools

Ce dépôt contient deux conteneurs [Docker](https://www.docker.com/) utiles à la réalisation de vos projets Dockerisés.
On trouve le reverse proxy HTTP nommé [Traefik](https://docs.traefik.io/) et une interface de gestion des hôtes Docker, [Portainer](https://portainer.io/).

## Dépendances

- [Docker 18.06.1](https://docs.docker.com/install/)
- [Docker Compose 1.22.0 (v3.5)](https://docs.docker.com/compose/)

## Description

| Service | Name | Frontend (`TRAEFIK_DOMAIN=traefik.docker`) | Description |
|:--------|:-----|:---------|:------------|
| [Traefik](https://docs.traefik.io/) | traefik | http://traefik-dashboard.traefik.docker/ | Traefik est un service de mandataire inverse (reverse-proxy) dynamique réalisé en Go par le français Emile Vauge il y a quelques petites années. |

## Utilisation globale

Tout d'abord, il faut copier le fichier `env.dist`
```bash
cp .env.dist .env
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

Vous pouvez changer la valeur de la variable `TRAEFIK_DOMAIN` avant de lancer Traefik, cette valeur sera le domaine de tous vos services.
Par exemple `portainer.traefik.docker` pour le service Portainer avec `TRAEFIK_DOMAIN=traefik.docker`.

Deux variables supplémentaire sont à disposition, `TRAEFIK_DEBUG` et `TRAEFIK_LOG_LEVEL` qui respectivement permettent d'activer ou non le debug et d'en préciser le niveau (INFO, DEBUG ou ERROR)

### Utilisateurs Linux

Généralement, les distributions linux ont toujours un résolveur dns (pour les distributions ubuntu, il existe un service dnsmasq qui gère la résolution par exemple). 
Il faut donc réaliser quelques actions avant de lancer traefik:
* Ajoutez la ligne suivante à votre fichier `/etc/NetworkManager/dnsmasq.d/dnsmasq.conf`.
```
# /etc/NetworkManager/dnsmasq.d/dnsmasq.conf
address=/.docker/127.0.0.1
```

### HTTPS

Un certificat auto-signé est généré dans le conteneur lors de la première installation, le https est donc disponible sur tous les services.

### Allez encore plus loin !

Il est possible d'utiliser son propre certificat, pour cela il est nécessaire de placer les fichiers dans les dossiers correspondants:
* `proxy/traefik/ssl/ca`
* `proxy/traefik/ssl/certs`
* `proxy/traefik/ssl/private`

De cette façon, vous pourrez utiliser un certificat signé par votre propre autorité.

**Aide :** [Générer une autorité et des certificats signés par celle-ci](https://jamielinux.com/docs/openssl-certificate-authority/index.html)
