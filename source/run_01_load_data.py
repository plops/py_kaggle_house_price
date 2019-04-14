"""load data.
Usage:
  run_01_load_data [-vh] [-f N_FOLDS] [-e N_ESTIMATORS]

Options:
  -h --help               Show this screen
  -v --verbose            Print debugging output
  -f N_FOLDS              number of folds for stratified k fold [default: 10]
  -e N_ESTIMATORS         number of estimators in the random forest classifier [default: 100]
"""
# 2019-04-14 martin kielhorn
# https://github.com/emanuele/kaggle_pbr/blob/master/blend.py
# https://www.kaggle.com/surya635/house-price-prediction
import matplotlib
import matplotlib.pyplot as plt
plt.ion()
font={("size"):("5")}
matplotlib.rc("font", **font)
import seaborn as sns
import sys
import time
import docopt
import pandas as pd
import numpy as np
import sklearn.ensemble
import sklearn.model_selection
args=docopt.docopt(__doc__, version="0.0.1")
if ( args["--verbose"] ):
    print(args)
def current_milli_time():
    return int(round(((1000)*(time.time()))))
global g_last_timestamp
g_last_timestamp=current_milli_time()
def milli_since_last():
    global g_last_timestamp
    current_time=current_milli_time()
    res=((current_time)-(g_last_timestamp))
    g_last_timestamp=current_time
    return res
class bcolors():
    OKGREEN="\033[92m"
    WARNING="\033[93m"
    FAIL="\033[91m"
    ENDC="\033[0m"
def plog(msg):
    print((("{:8d} PLOG ".format(milli_since_last()))+(msg)))
    sys.stdout.flush()
def log(msg):
    print(((bcolors.OKGREEN)+("{:8d} LOG ".format(milli_since_last()))+(msg)+(bcolors.ENDC)))
    sys.stdout.flush()
def fail(msg):
    print(((bcolors.FAIL)+("{:8d} FAIL ".format(milli_since_last()))+(msg)+(bcolors.ENDC)))
    sys.stdout.flush()
def warn(msg):
    print(((bcolors.WARNING)+("{:8d} WARNING ".format(milli_since_last()))+(msg)+(bcolors.ENDC)))
    sys.stdout.flush()
df=pd.read_csv("../data/train.csv")
warn("these columns have missing entries: {}".format(list(df.columns[df.isnull().any()])))
df_features=df.drop(columns=["SalePrice"])
y=np.log1p(df.SalePrice)
X=df_features.values
skf=sklearn.model_selection.StratifiedKFold(n_splits=int(args["-f"]), random_state=None, shuffle=False)
clf=sklearn.ensemble.RandomForestClassifier(n_estimators=int(args["-e"]), n_jobs=-1, criterion="gini")
for train_index, test_index in skf.split(X, y):
    clf.fit(X[train_index], y[train_index])
    y_submission=clf.predict_proba(X[test_index])[:,1]
    plog(y_submission)