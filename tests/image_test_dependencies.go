package tests

import (
	// This is a workaround for the fact that glide seems not to recursively resolve packages needed
	// only for testing.
	_ "k8s.io/kubernetes/pkg/client/unversioned"
)
