package main

import (
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
)

func RequestTest(t *testing.T) {
	handler := func(w http.ResponseWriter, r *http.Request) {
		_, err := io.WriteString(w, "Test\n")
		if err != nil {
			log.Fatal(err)
		}
	}

	req := httptest.NewRequest("GET", "http://localhost", nil)
	w := httptest.NewRecorder()
	handler(w, req)

	resp := w.Result()
	body, _ := io.ReadAll(resp.Body)

	fmt.Println(resp.StatusCode)
	fmt.Println(resp.Header.Get("Content-Type"))
	fmt.Println(string(body))
}