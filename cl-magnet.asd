#|
  This file is a part of cl-magnet project.
|#

#|
  A magnet link decoder for common lisp
|#

(in-package :cl-user)
(defpackage cl-magnet-asd
  (:use :cl :asdf))
(in-package :cl-magnet-asd)

(defsystem cl-magnet
  :version "0.1"
  :author ""
  :license ""
  :depends-on (:cl-annot 
               :do-urlencode
               :ironclad
               :cl-ppcre
               :cl-base32)
  :components ((:module "src"
                :serial t
                :components
                ((:file "utils")
                 (:file "cl-magnet"))))
  :description "A magnet link decoder for common lisp"
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (load-op cl-magnet-test))))
