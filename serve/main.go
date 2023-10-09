package main

import (
	"log"
	"net/http"
)

func createPingServerMux() *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("/ping", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("Received request from %s", r.RemoteAddr)
		w.WriteHeader(http.StatusNoContent)
	})
	return mux
}

func main() {
	mux := createPingServerMux()
	log.Printf("Listening on port 8080")
	_ = http.ListenAndServe(":8080", mux)
}
