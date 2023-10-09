package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestPerformHealthCheck(t *testing.T) {
	testServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/ping" {
			w.WriteHeader(http.StatusNoContent)
		} else {
			w.WriteHeader(http.StatusNotFound)
		}
	}))
	defer testServer.Close()

	// Test for the /ping URL
	success := PerformHealthCheck(testServer.URL + "/ping")
	if !success {
		t.Errorf("Expected true for /ping, got false")
	}

	// Test for a URL that is not found
	success = PerformHealthCheck(testServer.URL + "/notfound")
	if success {
		t.Errorf("Expected false for /notfound, got true")
	}
}
