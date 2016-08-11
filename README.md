# !!! micro-kube and classic micro-kube are deprecated !!!

## TL;DR

All variants of micro-kube are deprecated in favor of [minikube](https://github.com/kubernetes/minikube) and [kmachine](https://github.com/skippbox/kmachine)-- both of which are better, more mature options for quickly creating single-node Kubernetes clusters to facilitate education, experimentation, and development.

## The whole story

Classic micro-kube is a fast way to get up and running with a single-node Kubernetes cluster, _but_ it requires you to first clone this source code.  This implicitly makes git a dependency.  Additionally, classic micro-kube relies on vagrant (in addition to a virtualization provider like VirtualBox).  For ease of use, these dependencies are no longer desirable, so micro-kube began to evolve...

Development of the next major version of micro-kube _moved_ to the following repositories:

* [micro-kube/images](https://github.com/micro-kube/images)-- Packer-based builds of images for a variety of virtualization providers.  Such images include pre-pulled Docker images for all Kubernetes and micro-kube components so that micro-kube VMs start as fast as possible _and_ can be started offline.

* [micro-kube/cli](https://github.com/micro-kube/cli)-- A handy and _simple_ command line interface for downloading micro-kube VM images and launching them using the virtualization provider of your choice.

_However..._

As work on the CLI progressed, the tool that was emerging began to feel very familiar-- it simply felt like a Kubernetes-aware, albeit generally less capable rip-off of [docker-machine](https://github.com/docker/machine). Briefly, it was considered that forking and enhancing docker-machine might prove to be a better approach than continuing to cultivate a new CLI from scratch. As it turned out, someone else was already doing that-- [kmachine](https://github.com/skippbox/kmachine).

As it would happen, the developers of kmachine aren't certain of kmachine's future, given the development of a well-polished, _official_ option from Kubernetes for creating local, single-node Kubernetes clusters-- [minikube](https://github.com/kubernetes/minikube).

Given the existence of these excellent tools, there is no reason, at this time, for micro-kube development to continue.

For anyone in need of a _local_, single-node Kubernetes cluster, [minikube](https://github.com/kubernetes/minikube)  is likely the best option, although Windows support is only experimental at this time.

For anyone using Windows or wishing to create single-node Kubernetes clusters in the cloud, [kmachine](https://github.com/skippbox/kmachine) remains a tremendous option.

We now return you to your regularly scheduled documentation...

# micro-kube

__Please note that this repository and documentation is for "classic" micro-kube.__

**micro-kube** is the fastest way to start a fully-functional, single-node
[Kubernetes](http://kubernetes.io/) cluster using [CoreOS](https://coreos.com/) on
[Vagrant](https://www.vagrantup.com/).


## Getting started

Getting started with micro-kube on a Mac or Linux machine is incredibly easy as long as you have
Vagrant already installed and functioning properly.

Just clone this repository and `vagrant up`!

```
$ git clone git@github.com:micro-kube/micro-kube.git
$ cd micro-kube
$ vagrant up
```

Allow a couple minutes after starting for all services to become fully function.  Wait time may
vary with the speed of your internet connection.

The Kubernetes API will be available at http://172.17.8.100:8080 and https://172.17.8.100:6443

The Kubernetes UI (a dashboard application) will be available at
http://kube-ui.kube-system.micro-kube.172.17.8.100.xip.io

## Installing kubectl

If this is your first time exploring Kubernetes and you don't already have the __kubectl__ tool
installed, follow the installation directions
[here](http://kubernetes.io/v1.0/docs/getting-started-guides/aws/kubectl.html).

## Configuring kubectl

micro-kube exposes both secure and insecure API endpoints.  As such, either of the following
configurations will adequately prepare your kubectl tool to interact with micro-kube.

__Insecure:__

From the micro-kube directory:

```
$ kubectl config set-cluster micro-kube-insecure --server=http://172.17.8.100:8080
$ kubectl config set-context micro-kube-insecure --cluster=micro-kube-insecure
$ kubectl config use-context micro-kube-insecure
```

__Secure:__

From the micro-kube directory:

```
$ kubectl config set-cluster micro-kube-secure --server=https://172.17.8.100:6443 --certificate-authority=$(pwd)/ssl/ca.pem
$ kubectl config set-credentials micro-kube-admin --client-certificate=$(pwd)/ssl/admin.pem --client-key=$(pwd)/ssl/admin-key.pem
$ kubectl config set-context micro-kube-secure --cluster=micro-kube-secure --user=micro-kube-admin
$ kubectl config use-context micro-kube-secure
```

## Configuration options

micro-kube does not expose many configuration options.  The few available can be tweaked by
providing a `config.rb` file.

micro-kube comes with sample configuration which also contains documentation for each option.  You
can create your own `config.rb` by copying and modifying this sample.

From the micro-kube directory:

```
$ cp config.rb.sample config.rb
```

## How it works

micro-kube's `Vagrantfile` uses cloud-config found in the file `user-data`.  This includes various
scripts and systemd units required to download and start just one binary:

* kubelet

A kubelet is a Kubernetes agent that typically runs on every node-- of course micro-kube has just
one node.  It is able to start pods and their constituent containers at the behest of the
scheduler, but it can _also_ be configured to start pods whose manifests are stored locally on
disk.  micro-kube uses that strategy to compel the kubelet to launch the rest of the Kubernetes
components in pods within a `kube-system` namespace.  These include:

* kube-apiserver
* kube-controller-manager
* kube-scheduler
* kube-proxy

micro-kube also starts two Kubernetes add-ons by using the kubectl tool directly to create
requisite replication controllers and services _after_ the containerized kube-apiserver becomes
available.  These add-ons include:

* [kube-ui](https://github.com/kubernetes/kube-ui)
* [kube-dns](https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/dns)

## Troubleshooting

Although this should be a rare event, if micro-kube should happen to not function as expected, one
can begin to troubleshoot by checking the status of various Kubernetes components and inspecting
their logs.

### Troubleshooting the kubelet

The kubelet is the one kubernetes component that is started from a binary.  To check its status,
one must first ssh to the micro-kube VM.

From the micro-kube directory:

```
$ vagrant ssh
```

To check status:

```
$ sudo systemctl status kubelet
```

To view logs:

```
$ sudo journalctl -fu kubelet
```

### Troubleshooting other components

In micro-kube, all other components _of_ Kubernetes are managed _by_ Kubernetes.  To list the pods
that comprise the `kube-system` namespace:

```
$ kubectl get pods --namespace=kube-system
```

You can view logs for any pod in the `kube-system` namespace like so:

```
$ kubectl logs <pod name> --namespace=kube-system
```

## Limitations

* Kubernetes services are exposed using virtual IPs that are meaningless outside of the Kubernetes
  cluster.  (In micro-kube's case, meaningless outside of the Vagrant VM).  In the case of
  services exposing port 80 for HTTP traffic, the micro-kube-router component (which uses Nginx)
  dynamically reflects those services through virtual hosts on the VM's own port 80, but
  services running on other ports or using other protocols are not reflected.


## Contributing

micro-kube is no longer under active development.
