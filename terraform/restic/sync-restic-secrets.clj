#!/usr/bin/env bb

(require '[babashka.process :refer [shell]]
         '[cheshire.core :as json]
         '[clojure.string :as str]
         '[clojure.java.io :as io]
         '[clj-yaml.core :as yaml])

(def script-root (.getParentFile (io/file *file*)))

(defn git-root
  []
  (-> (:out (shell {:out :string
                    :dir script-root} "git rev-parse --show-toplevel"))
      (str/trim)))

(defn terraform-output
  []
  (as-> (:out (shell {:out :string
                      :dir script-root} "terraform output -json")) $
    (json/parse-string $ true)
    (reduce-kv (fn [acc k {:keys [value]}] (assoc acc k value)) {} $)
    (:secrets $)))

(defn secrets-path
  [machine]
  (str "sops -d machines/" machine "/secrets.yaml"))


(defn sops-decrypt
  [machine]
  (->> (secrets-path machine)
       (shell {:dir (git-root)
               :out :string})
       :out
       (yaml/parse-string)))

(defn sops-set
  [machine k v]
  (let [current (get-in (sops-decrypt machine) k)]
    (if (= current v)
      (println (str "Skip " machine "/" k ": unchanged"))
      (->> (str "sops --set '"
                (str/join (map (comp json/generate-string vector) k))
                " "
                (json/generate-string v)
                "' machines/" machine "/secrets.yaml")
           (shell {:dir (git-root)
                   :out :string
                   :err :string})))))

(defn -main
  []
  (doseq [[machine m] (terraform-output)]
    (sops-set (name machine) [:restic] m)))

(when (= *file* (System/getProperty "babashka.file"))
  (-main))

(comment
  @(def output (terraform-output))
  (sops-decrypt "iapetus")
  (-main))
