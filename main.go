package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"os/signal"
	"time"

	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
)

type Item struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

func getItems(w http.ResponseWriter, r *http.Request) {
	// Add logging for the client access
	log.Printf("Request from: %s, Endpoint: %s %s", r.RemoteAddr, r.Method, r.URL.Path)

	items := []Item{
		{ID: 1, Name: "Item 1 - prod!!!!!!"},
		{ID: 2, Name: "Item 2 - prod!!!!!!"},
		{ID: 3, Name: "Item 3 PROD Nih!!!!!!"},
		{ID: 4, Name: "Item 4 PROD Nih!!!!!!"},
	}
	envTier := os.Getenv("ENV_TIER")
	if envTier == "dev" {
		items = []Item{
			{ID: 1, Name: "Item 1 - dev"},
			{ID: 2, Name: "Item 2 - dev"},
			{ID: 3, Name: os.Getenv("ENV_ITEM_3")}, // Use general name for this envar
			{ID: 4, Name: os.Getenv("ENV_ITEM_4")}, // Use general name for this envar
		}
	} else if envTier == "stg" {
		items = []Item{
			{ID: 1, Name: "Item 1 - stg"},
			{ID: 2, Name: "Item 2 - stg"},
			{ID: 3, Name: os.Getenv("ENV_ITEM_3")}, // Use general name for this envar
			{ID: 4, Name: os.Getenv("ENV_ITEM_4")}, // Use general name for this envar
		}
	}
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Content-Type", "application/json")
	// Check the error returned by Encode
	if err := json.NewEncoder(w).Encode(items); err != nil {
		// Handle the error
		log.Println("Error encoding JSON:", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
	}
}

func main() {
	router := mux.NewRouter()
	corsOpts := handlers.CORS(
		handlers.AllowedOrigins([]string{"*"}),
		handlers.AllowedMethods([]string{"GET", "POST", "PUT", "DELETE"}),
		handlers.AllowedHeaders([]string{"Content-Type"}),
	)

	router.HandleFunc("/items", getItems).Methods("GET")

	// Logging middleware
	loggedRouter := handlers.LoggingHandler(os.Stdout, corsOpts(router))

	srv := &http.Server{
		Addr:    ":8080",
		Handler: loggedRouter,
	}

	// Graceful shutdown
	go func() {
		sigint := make(chan os.Signal, 1)
		signal.Notify(sigint, os.Interrupt)
		<-sigint

		log.Println("Shutting down gracefully....")
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		if err := srv.Shutdown(ctx); err != nil {
			log.Printf("Error during server shutdown: %v", err)
		}

		log.Println("Server gracefully stopped yuhuuu!!.")
	}()

	log.Println("API is running on port 8080....")
	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("Error starting server: %v", err)
	}
}
