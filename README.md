## Looking to exec arbitrary net scope commands in K8s Pod?

### What is podnetenter?
It is a tool allowing to enter into K8s Pod's network(sandbox network).

`podnetenter` can do many useful things, for example
- shoot network problem in Pod with distroless images, using tcpdump/iproute2/iptables provide by podnetenter
- setup network interface even Pod is running

### How to

run Pod x
```
kubectl run pause --image zengxu/pause:3.9
```

get pod status
```
k get po pause -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP          NODE 
pause   1/1     Running   0          9s    10.16.0.85  work-1
```
show iproute/iptables using podnetenter
```
apiVersion: v1
kind: Pod
metadata:
  name: show-pause
spec:
  nodeName: work-1
  restartPolicy: OnFailure
  hostPID: true
  containers:
    - name: netenter
      image: zengxu/podnetenter
      args: ["bash", "-c","ip addr && ip route && iptables-legacy-save"]
      env:
        - name: POD_NAME
          value: pause
        - name: NAMESPACE
          value: default
        - name: CONTAINER_RUNTIME_ENDPOINT
          value: "unix:///host/run/containerd/containerd.sock"
      volumeMounts:
        - mountPath: /host/run/containerd/containerd.sock
          name: crisock
      securityContext:
        privileged: true
        allowPrivilegeEscalation: true
  volumes:
    - name: crisock
      hostPath:
        path: /run/containerd/containerd.sock
```

Docker at Worker Node
```
docker run --rm -it --privileged --cgroupns=host -e NAMESPACE=default -e POD_NAME=x -v /proc:/proc -e CONTAINER_RUNTIME_ENDPOINT=unix:///run/containerd/containerd.sock -v /run/containerd/containerd.sock:/run/containerd/containerd.sock zengxu/podnetenter ip a
```

