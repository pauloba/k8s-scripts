
## Purpose of the script
Simple script to cleanup forgotten/orphaned/error-ed pods.

You need to troubleshoot and fix the error first, once you do you may end up with a ton of pods across several namespaces that can be deleted running the script on this repo.

|POD STATUS| SCRIPT USE CASE|TROUBLESHOOTING|
|--|--|--|
|`CrashLoopBackOff`| You have debugged and found out the reason for the crash and you want to remove several pods in this status across multiple namespaces. | Start by checking pod events `kubectl describe pods ${POD_NAME}`|
|`Error` | You fixed the error and want to remove several pods across several namespaces. | Diagnose the issue by [following the k8s guide](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/#diagnosing-the-problem).|
|`ErrImagePull` | You found out that there was a permission issue, you've fixed it and want to remove all error-ed pods.|Check container registry and service account permissions.|
|`ImagePullBackOff`|You fixed the image error and you want to delete the pods with errors.|The node fails to pull an image. Make sure the pod’s image path is valid. Check for incorrect login credentials or an exhausted rate limiting allowance. Using `kubectl describe pod` exposes the sequence of events that led to the failure. Finally make sure the remote registry server is actually up.|
|`NodeAffinity`| You are cutting on costs, and have spot VMs on the developlment environment, you find lots of garbage pods wit this status daily and want to get rid of them.|-|
|`NodeShutdown`| Same or similar situation as with pods with status NodeAffinitty.|-|
|`Pending`| Pending pods usually transition to Running status on their own as the Kubernetes scheduler assigns them to suitable nodes. However, in some scenarios, Pending pods will fail to get scheduled until you fix the underlying problem. | Check node-based scheduling constraints including readiness and taints, chec pods requested resources exceeding allocatable capacity, check for persistentVolume-related issues, review pod affinity/anti-affinity rules, review rolling update deployment settings.|
|`Terminated`| Pods that have not been garbage-collected by k8s for any reason and you want to get rid of them.|-|


## Cleaning up k8s clusters
Kubernetes has a built-in garabage collection system that can clean up unused images. 


It’s managed by Kubelet, the Kubernetes worker process that runs on each node.


You can tunne the kubelet using a config. file and setting the parameters described in [the official documentation](https://kubernetes.io/docs/concepts/architecture/garbage-collection/#containers-images)

Kubelet automatically monitors unused images and will remove them periodically. 

There are other solutions for cleaning up k8s clusters, when k8s garbage collector is not enougugh, such as:
- Manual cleanup
  - Clean up Pods in Evicted state
    - `kubectl get pods --all-namespaces -o wide | grep Evicted | awk '{print $1,$2}' | xargs -L1 kubectl delete pod -n`
  - Clean up Pods in Error state
    - `kubectl get pods --all-namespaces -o wide | grep Error | awk '{print $1,$2}' | xargs -L1 kubectl delete pod -n`
  - Clearing the Completed state of Pods
    - `kubectl get pods --all-namespaces -o wide | grep Completed | awk '{print $1,$2}' | xargs -L1 kubectl delete pod -n`
  - Clean up unused PVs
    - `kubectl describe -A pvc | grep -E "^Name:.*$|^Namespace:.*$|^Used By:.*$" | grep -B 2 "<none>" | grep -E "^Name:.*$|^Namespace:.*$" | cut -f2 -d: | paste -d " " - - | xargs -n2 bash -c 'kubectl -n ${1} delete pvc ${0}'`
  - Clear PVCs that are not bound
    - `kubectl get pvc --all-namespaces | tail -n +2 | grep -v Bound | awk '{print $1,$2}' | xargs -L1 kubectl delete pvc -n`
  - Clear the PVs that are not bound
    - `kubectl get pv | tail -n +2 | grep -v Bound | awk '{print $1}' | xargs -L1 kubectl delete pv`

- Prevention with limits on resources: https://martinheinz.dev/blog/60
- Automated finding of unused resources
  - [kube-janitor](https://codeberg.org/hjacobs/kube-janitor)  runs as a workload on your cluster and uses JSON queries to find resources which then can be deleted based on specified TTL or expiry date.
  - [K8sPurger](https://github.com/yogeshkk/k8spurger) finds and lists unused resources.