package main

import (
	"io/ioutil"
	"log"
	"net/http"
)

type example struct {
	test string
}

func test(rw http.ResponseWriter, req *http.Request) {
	body, err := ioutil.ReadAll(req.Body)
	if err != nil {
		panic(err)
	}
	log.Println(string(body))
}

func main() {
	http.HandleFunc("/test", test)
	log.Println("starting server:")
	log.Fatal(http.ListenAndServe(":81", nil))
}
