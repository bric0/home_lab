Pour générer les manifests lors de l'installation de talos: 
```
helm template cilium cilium/cilium \
    --version 1.18.6 \
    --namespace kube-system \
    -f ./values/cilium-values.yaml > ./manifests/cilium.yaml
```

Bien mettre le paramètre `securityContext.capabilities.mountCgroup=...` si non l'init-container de cilium `apply-sysctl-overwires` ne fonctionne pas. 

Il faut aussi installer le driver CSI. On va utiliser celui-ci [Proxmox CSI](https://github.com/sergelogvinov/proxmox-csi-plugin). 
Il faudra créer le rôle et l'utilisateur associer au CSI pour qu'il puisse créer des volumes sur le proxmox. 
Sur le pve-01 : 
```
pveum role add CSI -privs "VM.Audit VM.Config.Disk Datastore.Allocate Datastore.AllocateSpace Datastore.Audit"
pveum user add kubernetes-csi@pve
pveum aclmod / -user kubernetes-csi@pve -role CSI
```
Puis on récupère le token. 
```
pveum user token add kubernetes-csi@pve csi -privsep 0
```
Enfin, placer le token dans le fichier `talenv.yaml`. 


Pour installer la CSI de proxmox il lancer la commande suivante : 
```
helm template proxmox-csi-plugin oci://ghcr.io/sergelogvinov/charts/proxmox-csi-plugin \
    -n csi-proxmox \
    -f ./values/proxmox-csi-values.yaml > ./manifests/proxmox-csi.yaml
```
Il est censé avoir un pods du CSI sur chacun des noeuds plus un controller. 

Pour générer la configuration : 
```
talhelper genconfig -c talconfig.yaml -s talsecret.sops.yaml -e talenv.sops.yaml
```

Pour appliquer la configuration sur les noeuds Talos, il suffit de récupérer les IP dynamiques des machines créés puis d'appliquer cette configuration sur les machines : 
```
talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file clusterconfig/FILE_NAME.yaml
```

Pour installer Nextcloud avec [ce chart](https://github.com/nextcloud/helm/blob/main/charts/nextcloud/README.md): 
```
helm install nextcloud nextcloud/nextcloud \
    -f nextcloud-values.yaml \
    --namespace nextcloud --create-namespace
```
