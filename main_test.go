package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/gorilla/mux"
	"github.com/stretchr/testify/assert"
)

func TestGetItems(t *testing.T) {
	// Create a request to the /items endpoint
	req, err := http.NewRequest("GET", "/items", nil)
	if err != nil {
		t.Fatal(err)
	}

	// Create a response recorder to record the response
	rr := httptest.NewRecorder()

	// Create a test router and handler
	router := mux.NewRouter()
	router.HandleFunc("/items", getItems).Methods("GET")

	// Simulate the environment by setting ENV_TIER
	os.Setenv("ENV_TIER", "dev")

	// Perform the request
	router.ServeHTTP(rr, req)

	// Check the status code
	assert.Equal(t, http.StatusOK, rr.Code)

	// Parse the response body into a slice of items
	var items []Item
	err = json.Unmarshal(rr.Body.Bytes(), &items)
	if err != nil {
		t.Fatal(err)
	}

	// Check the content of the response
	expectedItems := []Item{
		{ID: 1, Name: "Item 1 - dev"},
		{ID: 2, Name: "Item 2 - dev"},
		{ID: 3, Name: os.Getenv("ENV_DEV_ITEM_3")},
		{ID: 4, Name: os.Getenv("ENV_DEV_ITEM_4")},
	}

	assert.Equal(t, expectedItems, items)
}
