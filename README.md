Pour générer les manifests lors de l'installation de talos: 
```
helm template \
    cilium \
    cilium/cilium \
    --version 1.18.0 \
    --namespace kube-system \
    --set ipam.mode=kubernetes \
    --set kubeProxyReplacement=true \
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set cgroup.autoMount.enabled=false \
    --set cgroup.hostRoot=/sys/fs/cgroup > ./manifests/cilium.yaml
```

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


Pour appliquer la configuration sur les noeuds Talos, il suffit de récupérer les IP dynamiques des machines créés puis d'appliquer cette configuration sur les machines : 
```
talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file clusterconfig/FILE_NAME.yaml
```
