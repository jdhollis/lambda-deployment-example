(ns lambda-deployment-example.stream-handler
  (:gen-class
    :implements [com.amazonaws.services.lambda.runtime.RequestStreamHandler]))

(defn -handleRequest [_ input-stream output-stream context]
  (println "This is it."))
