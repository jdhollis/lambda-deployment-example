(defproject lambda-deployment-example "0.1.0-SNAPSHOT"
  :description "Example of automated Lambda deployment with Terraform & CodePipeline"
  :url "https://github.com/jdhollis/lambda-deployment-example"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.9.0-alpha19"]
                 [com.amazonaws/aws-lambda-java-core "1.1.0"]]
  :profiles {:uberjar {:aot :all
                       :uberjar-name "lambda-deployment-example.jar"}})
