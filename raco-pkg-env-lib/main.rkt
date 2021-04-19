#lang racket/base

(require racket/file
         racket/format
         racket/pretty
         setup/dirs)

(define (install-environment! env-dir)
  (define env-config-dir (build-path env-dir "etc"))
  (define system-config-rktd
    (build-path (find-config-dir) "config.rktd"))

  (define system-config (file->value system-config-rktd))

  (define env-config
    (hash-set* system-config
               ;; changed keys
               'doc-dir
               (path->string (build-path env-dir "doc"))

               ;; added keys
               'default-scope
               "installation"

               'links-file
               (path->string (build-path env-dir "links.rktd"))

               'doc-search-dirs
               (list #f (path->string (find-doc-dir)))

               'links-search-files
               (list #f (path->string (find-links-file)))

               'pkgs-dir
               (path->string (build-path env-dir "pkgs"))

               'pkgs-search-dirs
               (list #f (path->string (find-pkgs-dir)))

               ;; random from uuidgen, maybe the user doesn't want to mess with this?
               ;; 'installation-name "b1760145-c765-4f74-ac27-bd5f441c60a5"
               ))

  (make-directory* env-config-dir)
  (call-with-output-file (build-path env-config-dir "config.rktd")
    (lambda (outp)
      (pretty-write env-config outp)))

  (call-with-output-file (build-path env-dir "activate.sh")
    (lambda (outp)
      (displayln (~a "export PLTCONFIGDIR=\"" env-config-dir "\"") outp))))

(module* main #f
  (require racket/match)
  (match (current-command-line-arguments)
    [(vector env-dir-string)
     (install-environment!
      (path->complete-path
       (string->path env-dir-string)))]))
