#!/usr/bin/env bb
(require '[babashka.cli :as cli]
         '[babashka.fs :as fs])

(defn resolve-store-path
  [path]
  (let [path (fs/real-path (fs/path path))]
    (when (not (fs/starts-with? path "/nix/store/"))
      (throw (ex-info (str "Not a store path: " path) {:path path})))
    path))

(defn resolve-gc-root
  [& segments]
  (->> (apply fs/path "/nix/var/nix/gcroots/per-user/" (System/getProperty "user.name") segments)
       (fs/create-dirs)))

(defn add-roots
  [{:keys [profile generation paths]}]
  (let [paths (map resolve-store-path paths)
        root (resolve-gc-root profile generation)]
    (fs/create-dirs root)
    (doseq [path paths]
      (let [target (fs/path root (fs/file-name path))]
        (println "Linking" (.toString path))
        (fs/delete-if-exists target)
        (fs/create-sym-link target path)))))

(defn collect-garbage
  [{:keys [profile max-count]}]
  (let [root (resolve-gc-root profile)
        delete (fn [{:keys [path]}]
                 (println "Unlinking" (.toString path))
                 (fs/delete-tree path))]
    (->> (fs/list-dir root)
         (map (fn [path]
                {:path path
                 :last-modified (fs/last-modified-time path)}))
         (sort-by :last-modified)
         (drop-last max-count)
         (map delete)
         (doall))))

(def common-spec
  {:profile {:coerce :string
             :require true}
   :max-count {:coerce :int}})

(def table
  [{:cmds ["clean"]
    :fn (fn [{:keys [opts]}] (collect-garbage opts))
    :spec (assoc-in common-spec [:max-count :require] true)}
   {:cmds ["add"]
    :fn (fn [{:keys [opts]}]
          (add-roots opts)
          (when (opts :max-count)
            (collect-garbage opts)))
    :spec (assoc common-spec
                 :generation {:coerce :string
                              :require true}
                 :paths {})
    :coerce {:paths []}
    :args->opts (repeat :paths)}])

(defn -main
  [& args]
  (cli/dispatch table args))

(when (= *file* (System/getProperty "babashka.file"))
  (apply -main *command-line-args*))

(comment
  (-main "clean"
         "--profile"
         "nix-config/master"
         "--max-count" 1
         "--generation"
         (java.time.Instant/now)
         "result-flakeInputs"
         "result-nixosConfigurations.iapetus"))
