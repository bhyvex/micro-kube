package microkube

import (
	"fmt"
	"log"
	"os"
	"testing"

	client "k8s.io/kubernetes/pkg/client/unversioned"
)

const (
	namespace = "kube-system"
)

var (
	ip            string
	podClient     client.PodInterface
	rcClient      client.ReplicationControllerInterface
	serviceClient client.ServiceInterface
)

func TestAPIServerPod(t *testing.T) {
	testSystemPod("kube-apiserver", t)
}

func TestControllerManagerPod(t *testing.T) {
	testSystemPod("kube-controller-manager", t)
}

func TestProxyPod(t *testing.T) {
	testSystemPod("kube-proxy", t)
}

func TestSchedulerPod(t *testing.T) {
	testSystemPod("kube-scheduler", t)
}

func TestKubeDNSReplicationController(t *testing.T) {
	testReplicationController("kube-dns", t)
}

func TestKubeUIReplicationController(t *testing.T) {
	testReplicationController("kube-ui", t)
}

func TestMicroKubeRouterReplicationController(t *testing.T) {
	testReplicationController("micro-kube-router", t)
}

func TestKubeDNSService(t *testing.T) {
	testService("kube-dns", t)
}

func TestKubeUIService(t *testing.T) {
	testService("kube-ui", t)
}

func testSystemPod(podBaseName string, t *testing.T) {
	podName := fmt.Sprintf("%s-%s", podBaseName, ip)
	_, err := podClient.Get(podName)
	if err != nil {
		t.Errorf("Error finding pod \"%s\": %s", podName, err)
	}
}

func testReplicationController(rcName string, t *testing.T) {
	_, err := rcClient.Get(rcName)
	if err != nil {
		t.Errorf("Error finding replication controller \"%s\": %s", rcName, err)
	}
}

func testService(svcName string, t *testing.T) {
	_, err := serviceClient.Get(svcName)
	if err != nil {
		t.Errorf("Error finding service \"%s\": %s", svcName, err)
	}
}

func TestMain(m *testing.M) {
	ip = os.Getenv("MK_IP")
	port := os.Getenv("MK_PORT")
	config := &client.Config{Host: fmt.Sprintf("%s:%s", ip, port)}
	kubeClient, err := client.New(config)
	if err != nil {
		log.Fatalf("Failed to create client: %v.", err)
	}
	podClient = kubeClient.Pods(namespace)
	rcClient = kubeClient.ReplicationControllers(namespace)
	serviceClient = kubeClient.Services(namespace)
	os.Exit(m.Run())
}
