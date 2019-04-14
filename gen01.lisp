(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-py-generator"))
(in-package :cl-py-generator)
(setf *features* (union *features* '(:plot))) 
(setf *features* (set-difference *features* '(:plot)))

(defun timer (name body)
  (let ((start (format nil "time_before_~a" name))
	(end (format nil "time_after_~a" name)))
   `(do0
     (setf ,start (current_milli_time))
     ,body
     (setf ,end (current_milli_time))
     (print (dot (string ,(format nil "~a time: {}ms" name))
		 (format (- ,end ,start)))))))

(progn
  (defparameter *path* "/home/martin/stage/py_kaggle_house_price")
  (defparameter *code-file* "run_01_load_data")
  (defparameter *source* (format nil "~a/source/~a" *path* *code-file*))
  (defparameter *house-facts*
    `((10 "")
      ))

  (let* ((code `(do0
		 (string3 ,(format nil "load data.
Usage:
  ~a [-vh]

Options:
  -h --help               Show this screen
  -v --verbose            Print debugging output
"
				   *code-file*))
		 "# 2019-04-14 martin kielhorn"
		 
		 ;;"from __future__ import print_function"
		 ;; "from __future__ import division"
			
		 (imports (
			   sys
			   time
			   docopt
			   (pd pandas)
			   (np numpy)))
			
		 (setf args (docopt.docopt __doc__ :version (string "0.0.1")))
		 (if (aref args (string "--verbose"))
		     (print args))
		 (def current_milli_time ()
			  (return (int (round (* 1000 (time.time))))))
		 (do0
		  "global g_last_timestamp"
		  (setf g_last_timestamp (current_milli_time))
		  (def milli_since_last ()
		    "global g_last_timestamp"
		    (setf current_time (current_milli_time)
			  res (- current_time g_last_timestamp)
			  g_last_timestamp current_time)
		    (return res)))
		 (do0
		  (class bcolors ()
			 (setf OKGREEN (string "\\033[92m")
			       WARNING (string "\\033[93m")
			       FAIL (string "\\033[91m")
			       ENDC (string "\\033[0m")))
		  

		  (def plog (msg)
		    (print (+ 
			    (dot (string "{:8d} PLOG ")
				 (format (milli_since_last)))
			    msg
			    ))
		    (sys.stdout.flush))
		  (def log (msg)
		    (print (+ bcolors.OKGREEN
			      (dot (string "{:8d} LOG ")
				   (format (milli_since_last)))
			      msg
			      bcolors.ENDC))
		    (sys.stdout.flush))
		  (def fail (msg)
		    (print (+ bcolors.FAIL
			      (dot (string "{:8d} FAIL ")
				   (format (milli_since_last)))
			      msg
			      bcolors.ENDC))
		    (sys.stdout.flush))
		  (def warn (msg)
		    (print (+ bcolors.WARNING
			      (dot (string "{:8d} WARNING ")
				   (format (milli_since_last)))
			      msg
			      bcolors.ENDC))
		    (sys.stdout.flush)))

		 (setf df (pd.read_csv (string "../data/train.csv"))))))
    (write-source *source* code)
    (write-source "/dev/shm/s" `(do0
				 ))))

