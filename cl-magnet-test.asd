#|
  This file is a part of cl-magnet project.
|#

(in-package :cl-user)
(defpackage cl-magnet-test-asd
  (:use :cl :asdf))
(in-package :cl-magnet-test-asd)

(defsystem cl-magnet-test
  :author ""
  :license ""
  :depends-on (:cl-magnet
               :cl-test-more)
  :components ((:module "t"
                :components
                ((:file "cl-magnet"))))
  :perform (load-op :after (op c) (asdf:clear-system c)))
