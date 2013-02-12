(in-package :cl-user)
(defpackage cl-magnet.utils
  (:use :cl))
(in-package :cl-magnet.utils)

(defun string->keyword (string)
  (intern (string-upcase string) :keyword))

(defun is-magnet (string)
  (not (null (cl-ppcre:scan "^ *magnet:" string))))

(defun split-magnet (string)
  "Split a magnet link and returns a two string list: (uri parameters)"
  (multiple-value-bind (discard result)
      (cl-ppcre:scan-to-strings "^ *magnet:([^?]*)\\?(.*)" string)
    (declare (ignore discard))
    (list (aref result 0) (aref result 1))))

(defun split-magnet-params (params-string)
  (mapcar (lambda (param) (cl-ppcre:split "=" param))
         (cl-ppcre:split "&" params-string)))

(defun clean-name (string)
  "Transforms names like 'xt.1' to 'xt'"
  (cl-ppcre:regex-replace "\\..*" string ""))
    
