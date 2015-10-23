# micro-kube

**micro-kube** is the fastest way to start a fully-functional, single-node [Kubernetes](http://kubernetes.io/) cluster using [CoreOS](https://coreos.com/) on [Vagrant](https://www.vagrantup.com/).

## Getting started

Getting started with micro-kube is incredibly easy as long as you have Vagrant already installed and functioning properly.

Just clone this repository and `vagrant up`!

```
$ git clone git@github.com:krancour/micro-kube.git
$ cd micro-kube
$ vagrant up
```

Allow a couple minutes after starting for all services to become fully function.  Wait time may vary with the speed of your internet connection.

The Kubernetes API will be available at [http://localhost:8080](http://localhost:8080)

The Kubernetes UI will be available at [http://localhost:8080/ui](http://localhost:8080/ui)

## Configuring kubectl

The following configuration will prepare your local kubectl tool to interact with micro-kube:

```
$ kubectl config set-cluster micro-kube --server=http://localhost:8080
$ kubectl config set-context micro-kube --cluster=micro-kube
$ kubectl config use-context micro-kube

```

## Configuration options

micro-kube does not expose many configuration options.  The few available can be tweaked by providing a `config.rb` file.

micro-kube comes with sample configuration which also contains documentation for each option.  You can create your own `config.rb` by copying and modifying this sample:

```
$ cp config.rb.sample config.rb
```

## How it works

micro-kube's `Vagrantfile` uses cloud-config found in the file `Userdata`.  This includes various scripts and systemd units required to download and start all of the following:

* kube-apiserver
* kube-controller-manager
* kube-scheduler
* kube-kubelet
* kube-proxy
* Two Kubernetes addons:
  * kube-ui
  * kube-dns (SkyDNS)

To troubleshoot individual components:

Check status:

```
$ vagrant ssh
$ sudo systemctl status <component name>
```

View logs:

```
$ sudo journalctl -f <component name>
```

## Contributing

Pull requests that make micro-kube more awesome are welcome!  The primary guideline for contribution is to keep things simple so micro-kube remains lightweight and easy-to-use.
