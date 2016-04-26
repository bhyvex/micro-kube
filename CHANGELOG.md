## v0.4.1 -> v0.4.2

### Maintenance

* Upgrade Kubernetes to v1.2.3

## v0.4.0 -> v0.4.1

### Maintenance

* Upgrade Kubernetes to v1.2.2
* Upgrade micro-kube-router to v0.2.0

## v0.3.0 -> v0.4.0

### Features

* Hypothetical support for Windows (untested)

### Maintenance

* Upgrade Kubernetes to v1.2.0
* Transition to static SSL configuration
* Fix broken tests
* Containerize tests

## v0.2.3 -> v0.3.0

### Features

* Enable the beta daemonsets API extension

### Maintenance

* Rename `_scripts/` directory to `scripts/`
* Separate micro-kube-router into its own repository
* Use micro-kube-router:v0.1.0

## v0.2.3 -> v0.2.4

### Fixes

* Upgrade to kube-ui v5 since the upgrade to Kubernetes v1.1.7 in micro-kube v0.2.3 proved incompatible with kube-ui v3.

### Documentation

* Add this changelog

### Maintenance

* Remove extraneous labels from kube-ui and kube-dns manifests
* Add the humble beginnings of a test suite

## v0.2.2 -> v0.2.3

### Maintenance

* Upgrade Kubernetes to v1.1.7
