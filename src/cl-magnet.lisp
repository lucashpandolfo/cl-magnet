(in-package :cl-user)
(defpackage cl-magnet
  (:use :cl :cl-magnet.utils))
(in-package :cl-magnet)

(cl-annot:enable-annot-syntax)

(defclass magnet ()
  ((data :initform (make-hash-table :test 'equal))))

(defmethod add-parameter ((this magnet) (parameter string) (value string))
  (add-specialized-parameter this (string->keyword (clean-name parameter)) value))

(defmethod add-specialized-parameter ((this magnet) parameter (value string))
  (with-slots ((data data)) this
    (pushnew (urlencode:urldecode value :lenientp t :queryp t) (gethash parameter data))))

(defmethod add-specialized-parameter ((this magnet) (parameter (eql :xt)) (value string))
  (with-slots ((data data)) this
    (multiple-value-bind (discard type-body) 
        (cl-ppcre:scan-to-strings "urn:([^:]*):(.*)" (string-downcase value))
      (declare (ignore discard))
      (let ((type (string->keyword (aref type-body 0)))
            (body (aref type-body 1)))
        (pushnew (xt-decode type body) (gethash parameter data))))))

;; XT decoders
(defun xt-base32 (name value)
  (let ((sha1 (cl-base32:base32-to-bytes (string-downcase value))))
    (list name sha1)))

(defun xt-hex (name value)
  (let ((hex (ironclad:hex-string-to-byte-array value)))
    (list name hex)))

(defmethod xt-decode ((type (eql :sha1)) (value string))
  (xt-base32 type value))

(defmethod xt-decode ((type (eql :bitprint)) (value string))
  (let ((hashes (cl-ppcre:split "\\." value)))
    (let ((sha1 (cl-base32:base32-to-bytes (string-downcase (car hashes))))
          (tth  (cl-base32:base32-to-bytes (string-downcase (cadr hashes)))))
      (list :bitprint sha1 tth))))

(defmethod xt-decode ((type (eql :ed2k)) (value string))
  (xt-hex type value))

(defmethod xt-decode ((type (eql :aich)) (value string))
  (xt-base32 type value))

(defmethod xt-decode ((type (eql :kzhash)) (value string))
  (xt-hex type value))

(defmethod xt-decode ((type (eql :btih)) (value string))
  (let ((hash
         (case (length value)
           (40 (ironclad:hex-string-to-byte-array value))
           (32 (base32:base32-to-bytes (string-downcase value)))
           (otherwise (error "BitTorrentInfoHash should be 40 or 32 bytes long")))))
    (list :btih hash)))

(defmethod xt-decode ((type (eql :md5)) (value string))
  (xt-hex type value))

;;Exported interface
(defmethod get-field-value ((this magnet) field)
  (with-slots ((data data)) this
    (gethash field data nil)))

@export
(defmethod display-name ((this magnet))
  (get-field-value this :dn))

@export
(defmethod exact-length ((this magnet))
  (get-field-value this :xl))

@export
(defmethod exact-topic ((this magnet))
  (get-field-value this :xt))

@export
(defmethod acceptable-source ((this magnet))
  (get-field-value this :as))

@export
(defmethod exact-source ((this magnet))
  (get-field-value this :xs))

@export
(defmethod keyword-topic ((this magnet))
  (get-field-value this :kt))

@export
(defmethod manifest-topic ((this magnet))
  (get-field-value this :mt))

@export
(defmethod address-tracker ((this magnet))
  (get-field-value this :tr))

@export
(defun parse (string)
  (unless (is-magnet string)
    (error "Not a magnet link (~a)" string))
  (let ((magnet (make-instance 'magnet))
        (info   (split-magnet string)))
    (let ((uri (car info))
          (params (split-magnet-params (cadr info))))
    (loop :for param :in params
       :do (add-parameter magnet (car param) (cadr param)))
    magnet)))
