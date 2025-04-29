# 📋 README — Sauvegarde Home Assistant vers PBS via NFS

## 🌟 Objectif
Automatiser la sauvegarde des snapshots de Home Assistant OS vers un répertoire NFS partagé sur un Proxmox Backup Server (PBS), pour archivage et conservation longue durée.

---

## 💪 Composants

| Élément              | Détail                          |
|----------------------|----------------------------------|
| 🏠 Home Assistant OS | IP : `192.168.1.80`              |
| 💻 PBS               | IP : `192.168.1.100`             |
| 📂 Répertoire cible  | `/mnt/ssd4to/ha/` sur PBS        |
| 📁 Point de montage HA | `/mnt/backup` (monté en NFS)     |

---

## 💠 1. Côté PBS : Configuration du partage NFS

### A. Installer le serveur NFS
```bash
apt update
apt install nfs-kernel-server
```

### B. Définir l’export
Modifier `/etc/exports` :
```bash
/mnt/ssd4to 192.168.1.80/32(rw,sync,no_subtree_check,no_root_squash)
```
Puis :
```bash
exportfs -ra
systemctl enable --now nfs-server
```

---

## 📪 2. Côté Home Assistant : Montage du partage NFS

Dans le terminal HA :
```bash
mkdir -p /mnt/backup
mount -t nfs 192.168.1.100:/mnt/ssd4to /mnt/backup
```
Vérifier avec :
```bash
ls /mnt/backup
```

---

## ♻️ 3. Rotation automatique : garder uniquement les **10 derniers fichiers**

### Script `cleanup_backups.sh`

```bash
#!/bin/bash
cd /mnt/ssd4to/ha || exit 1
ls -1t *.tar 2>/dev/null | tail -n +11 | xargs -r rm --
```

Rendre exécutable :
```bash
chmod +x /home/scripts/cleanup_backups.sh
```

Planification avec cron :
```bash
crontab -e
```
Ajouter :
```bash
0 4 * * * /home/scripts/cleanup_backups.sh >> /var/log/ha_backup_rotation.log 2>&1
```

---

## ✅ Résultat final

- Chaque nuit, Home Assistant peut créer un snapshot.
- Les sauvegardes sont copiées manuellement ou automatiquement vers PBS dans `/mnt/ssd4to/ha/`.
- Un script garde uniquement les **10 derniers fichiers** pour éviter d'encombrer l'espace disque.

---

# 📊 Notes additionnelles

- Tester le montage NFS à chaque reboot Home Assistant si non persistent.
- Possibilité d'ajouter une notification Telegram pour confirmer le succès de la sauvegarde.

