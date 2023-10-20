TODO: switch setup to kubespray or script
TODO: switch kubernetes yaml to kustomize (if not kubespray)

Manual from: https://github.com/NVIDIA/k8s-device-plugin#install-the-nvidia-container-toolkit

```
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/libnvidia-container.list

sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit

# Update containerd Configure the container runtime by using the nvidia-ctk command:
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
sudo nvidia-ctk runtime configure --runtime=containerd

sudo systemctl restart containerd
```

Create device plugin:

```
kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.1/nvidia-device-plugin.yml
```

Installed CUDA driver:

```
sudo apt install --only-upgrade ubuntu-drivers-common 

sudo ubuntu-drivers autoinstall

sudo shutdown -r now

nvidia-smi
```

> had strange kernel crashing problem, reverted and update/upgraded first then tried again. Also reverted containerd config (need to update for nvidia)


## label nodes

```
# For homelab, there's 1 node, on gke we should use taints / toleration
kubectl label nodes node1 nvidia.com/gpu=present
```

Demo

```
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  restartPolicy: Never
  containers:
    - name: cuda-container
      image: nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda10.2
      resources:
        limits:
          nvidia.com/gpu: 1
  nodeSelector:  # Added nodeSelector field
    nvidia.com/gpu: present
EOF
```