package main

import (
	"log"
	"net/http"
	"os"
)

func main() {
	success := PerformHealthCheck("http://localhost:8080/ping")
	if !success {
		log.Println("Healthcheck failed")
		os.Exit(1)
	}
	log.Println("Healthcheck successful")
}

func PerformHealthCheck(url string) bool {
	resp, err := http.Get(url)
	if err != nil {
		log.Printf("Healthcheck failed: %v", err)
		return false
	}
	if resp.StatusCode != http.StatusNoContent {
		log.Printf("Healthcheck failed: received status code %d", resp.StatusCode)
		return false
	}
	return true
}
