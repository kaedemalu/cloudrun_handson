# Hands on for Cloud Run
このリポジトリはGCPのハンズオンのコンテンツのひとつとして扱う、Cloud Runのためのリポジトリです。

## Cloud Runとは
Google Cloud Next 2019 SFで新たに発表されたサービスです。  
サーバーレスでコンテナアプリケーションを動かすことが可能であり、  
APIサーバーなど単体で動かしたり、GKEのadd onとしてGKE上にデプロイすることも可能です。  
バックエンドでは[Knative](https://cloud.google.com/knative/?hl=ja)で動いています。  
現在ではベータ版としてリリースされているためSLAなどの保証は現在のところはないです。(2019/05/05現在)  

## 今回使うもの
* `Dockerfile`  
  ```
  FROM golang:alpine AS build
  WORKDIR /app
  ADD . /app
  RUN cd /app && go build -o server

  FROM alpine
  RUN apk update && \
      apk add ca-certificates && \
      rm -rf /var/cache/apk/* 
  WORKDIR /app
  COPY --from=build /app/server /app

  EXPOSE 8080
  ENTRYPOINT ./server
  ```
  なるべく軽いコンテナイメージにするためにマルチステージビルドにしてあります。  
  Goはコンパイルする必要があるので、最初のビルドで`server.go`のコンパイルを行います。  
  続いて、素のalpine linuxにコンパイル済みのバイナリファイルをコピーしてそちらをメインのコンテナイメージとして使うようにしてあります。  
  <参考>  
  [小さなコンテナの組み立て（Kubernetes Best Practices）](https://www.youtube.com/watch?v=wGz_cbtCiEA&t=319s)  

* `server.go`
  ```
  package main

  import (
    "fmt"
    "net/http"
  )

  func main() {
    http.HandleFunc("/", handler)
    http.ListenAndServe(":8080", nil)
  }
  func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Your url path is %s", r.URL.Path[1:])

  }
  ```
  **Goのことは聞かないでください。**  
  `import`で2つライブラリをインポートして簡単なサーバーを立てられるようにしています。  
  <参考>  
  [golangでdockerをはじめる ~ goのwebサーバーをdockerでたててみた ~](https://qiita.com/vankobe/items/f4c09e8e4b580651b568)  

