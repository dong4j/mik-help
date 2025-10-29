package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"time"
)

const (
	uploadPath = "./uploads/"
	serverPort = "12345"
)

type UploadResponse struct {
	Data DataURL `json:"data"`
}

type DataURL struct {
	URL string `json:"url"`
}

func main() {
	// 确保上传目录存在
	if err := os.MkdirAll(uploadPath, os.ModePerm); err != nil {
		log.Fatal("Failed to create upload directory:", err)
	}

	http.HandleFunc("/upload", uploadHandler)
	http.Handle("/archive/", http.StripPrefix("/archive/", http.FileServer(http.Dir(uploadPath))))

	log.Printf("Server starting on http://localhost:%s\n", serverPort)
	log.Printf("Upload path: %s\n", uploadPath)
	if err := http.ListenAndServe(":"+serverPort, nil); err != nil {
		log.Fatal(err)
	}
}

func uploadHandler(w http.ResponseWriter, r *http.Request) {
	// 只允许 POST 请求
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// 解析 multipart form
	err := r.ParseMultipartForm(10 << 20) // 10 MB
	if err != nil {
		http.Error(w, "Failed to parse form", http.StatusBadRequest)
		return
	}

	// 获取文件
	file, handler, err := r.FormFile("fileName")
	if err != nil {
		http.Error(w, "Failed to get file", http.StatusBadRequest)
		return
	}
	defer file.Close()

	// 获取文件扩展名
	ext := filepath.Ext(handler.Filename)
	if ext == "" {
		http.Error(w, "Invalid file extension", http.StatusBadRequest)
		return
	}

	// 创建按类型分类的目录
	extDir := ext[1:] + "/"
	targetDir := filepath.Join(uploadPath, extDir)
	if err := os.MkdirAll(targetDir, os.ModePerm); err != nil {
		http.Error(w, "Failed to create directory", http.StatusInternalServerError)
		return
	}

	// 生成唯一文件名
	timestamp := strconv.FormatInt(time.Now().UnixNano()/1000000, 10)
	newFileName := timestamp + handler.Filename
	filePath := filepath.Join(targetDir, newFileName)

	// 保存文件
	dst, err := os.Create(filePath)
	if err != nil {
		http.Error(w, "Failed to create file", http.StatusInternalServerError)
		return
	}
	defer dst.Close()

	if _, err := io.Copy(dst, file); err != nil {
		http.Error(w, "Failed to save file", http.StatusInternalServerError)
		return
	}

	// 生成访问 URL
	scheme := "http"
	if r.TLS != nil {
		scheme = "https"
	}
	host := r.Host
	urlPath := fmt.Sprintf("%s://%s/archive/%s%s", scheme, host, extDir, newFileName)

	// 返回 JSON 响应
	response := UploadResponse{
		Data: DataURL{
			URL: urlPath,
		},
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)

	log.Printf("File uploaded successfully: %s\n", urlPath)
}
