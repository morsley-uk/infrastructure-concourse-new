apiVersion: v1
kind: PersistentVolume
metadata:
  name: concourse-worker-0
  labels:
    type: amazonEBS
    app: concourse-worker
    release: concourse
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: worker-storage-class
  awsElasticBlockStore:
    volumeID: ${VOLUME_ID}
#    fsType: gp2
    fsType: ext4