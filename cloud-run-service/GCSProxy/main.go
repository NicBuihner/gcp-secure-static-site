package main

import (
	"context"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"

	"cloud.google.com/go/storage"
)

func storageHandler() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Documentation says that the leading '/' can sometimes be omitted
		path := r.URL.Path
		if strings.HasPrefix(path, "/") {
			path = strings.TrimLeft(path, "/")
		}
		if strings.HasSuffix(path, "/") || path == "" {
			path = path + "index.html"
		}

		ctx := context.Background()
		client, err := storage.NewClient(ctx)
		if err != nil {
			fmt.Fprint(os.Stderr, "unable to storage.NewClient: "+err.Error())
			http.NotFound(w, r)
			return
		}

		fmt.Fprintf(os.Stderr, "Getting: %s - %s\n", os.Getenv("BUCKET_NAME"), path)

		objH := client.Bucket(os.Getenv("BUCKET_NAME")).Object(path)
		attrs, err := objH.Attrs(ctx)
		if err != nil {
			fmt.Fprint(os.Stderr, "unable to objH.Attrs: "+err.Error())
			http.NotFound(w, r)
			return
		}
		contentType := attrs.ContentType
		w.Header().Set("Content-Type", contentType)

		rc, err := objH.NewReader(ctx)
		if err != nil {
			fmt.Fprint(os.Stderr, "unable to objH.NewReader: "+err.Error())
			http.NotFound(w, r)
			return
		}
		defer rc.Close()

		_, err = io.Copy(w, rc)
		if err != nil {
			fmt.Fprint(os.Stderr, "unable to io.Copy: "+err.Error())
			http.NotFound(w, r)
			return
		}
	}
}

func main() {
	http.HandleFunc("/", storageHandler())

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	err := http.ListenAndServe(":"+port, nil)
	if err != nil {
		log.Fatal(err)
	}
}
