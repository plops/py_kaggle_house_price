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
  ~a [-vh] [-f N_FOLDS] [-e N_ESTIMATORS]

Options:
  -h --help               Show this screen
  -v --verbose            Print debugging output
  -f N_FOLDS              number of folds for stratified k fold [default: 10]
  -e N_ESTIMATORS         number of estimators in the random forest classifier [default: 100]
"
				   *code-file*))
		 "# 2019-04-14 martin kielhorn"
		 
		 ;;"from __future__ import print_function"
		 ;; "from __future__ import division"
		 "# https://github.com/emanuele/kaggle_pbr/blob/master/blend.py"
		 "# https://www.kaggle.com/surya635/house-price-prediction"
		 (do0
		  (imports (matplotlib))
	     	  (imports ((plt matplotlib.pyplot)))
		  
		  (do0
		   (plt.ion)
		   (setf font (dict ((string size) (string 5))))
		   (matplotlib.rc (string "font") **font)))
		 
		 
		 (imports ((sns seaborn)
			   sys
			   time
			   docopt
			   (pd pandas)
			   (np numpy)
			   sklearn.ensemble
			   sklearn.model_selection))
					
					
		 
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

		 (setf df (pd.read_csv (string "../data/train.csv")))
		 (do0
		  (warn (dot (string "these columns have missing entries: {}")
			     (format
			      ("list"
			       (aref df.columns
				     (dot (df.isnull)
					  (any)))))))
		  (sns.heatmap (df.isnull)))
		 
		 (setf df_features (df.drop :columns (list (string "SalePrice"))))
		 (do0
		  (plog (string "correlation of columns with numerical values"))
		  (setf df_num (dot (df.select_dtypes :include (list np.number))
					     (drop :columns (list (string "Id"))))
			df_num_corr (df_num.corr)
			df_num_top_feature (aref df_num_corr.index
						 (< .5 (aref df_num_corr (string "SalePrice"))))
			df_num_top_corr (dot (aref df_num df_num_top_feature)
					     (corr)))
		  (sns.heatmap df_num_top_corr :annot True))
		 
		 
		 (setf y (np.log1p df.SalePrice) ;; log makes distribution more normal
		       X df_features.values)
		 (setf skf (sklearn.model_selection.StratifiedKFold :n_splits (int (aref args (string "-f"))) :random_state None :shuffle False))
		 (setf clf
		       (sklearn.ensemble.RandomForestClassifier
			:n_estimators (int (aref args (string "-e")))
			:n_jobs -1 ;; all processors
			:criterion (string "gini")))
		 (for ((ntuple train_index test_index) (skf.split X y))
		      (clf.fit (aref X train_index)
			       (aref y train_index))
		      (setf y_submission (aref (clf.predict_proba (aref X test_index)) ":" 1))
		      (plog y_submission)))))
    
    
    (write-source *source* code)
    (write-source "/dev/shm/s" `(do0
				 ))))

