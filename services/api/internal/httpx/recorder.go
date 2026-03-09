package httpx

import "net/http"

// Recorder wraps ResponseWriter to capture status code.
type Recorder struct {
	http.ResponseWriter
	Code int
}

func NewRecorder(w http.ResponseWriter) *Recorder {
	return &Recorder{ResponseWriter: w, Code: 200}
}

func (r *Recorder) WriteHeader(statusCode int) {
	r.Code = statusCode
	r.ResponseWriter.WriteHeader(statusCode)
}
