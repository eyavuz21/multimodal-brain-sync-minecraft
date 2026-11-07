"""Trial-level CBSI coherence (1 Hz) and average distance between predators during Hunt trials.
Input to rerun_distance_henrik_model.R."""
import sys,os,warnings; warnings.filterwarnings('ignore')
import numpy as np,pandas as pd,scipy.io as sio
from scipy.signal import resample_poly
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from wtc_python import wcoherence
G,OUT=sys.argv[1:3]; glm=G+'/GLM Data'; pairs=pd.read_csv(G+'/Wavelet Coherence/pairTable.csv')
B={'Low':(.02,.03),'Mid':(.03,.1),'High':(.1,.2001)}; rows=[]
for _,r in pairs.iterrows():
    p1,p2=r.Member1,r.Member2
    o=sio.loadmat(f'{glm}/{p1}/Logs/Onsets/{p1}U_onsets.mat',squeeze_me=True,struct_as_record=False)
    U=np.unique(np.c_[np.atleast_1d(o['onsets'][1]).ravel(),np.atleast_1d(o['durations'][1]).ravel()],axis=0)
    F=pd.read_excel(f'{G}/FINALFRAME Participant Data/FINALFRAME_{p1}.xlsx')
    L=lambda p:resample_poly(sio.loadmat(f'{glm}/{p}/Processed Data/preprocessed.mat',squeeze_me=True,struct_as_record=False,variable_names=['Data'])['Data'].HbOCBSI,1,25,axis=0)
    X,Y=L(p1),L(p2); n=min(len(X),len(Y))
    for c in range(25):
        w,f=wcoherence(X[:n,c],Y[:n,c],fs=1.0)
        for tr,(on,du) in enumerate(U):
            s=int(round(on));e=min(int(round(on+du))+1,n); g=F[(F.Time>=s+1)&(F.Time<=e)].OtherDistHunt.astype(float); g=g[g>0]
            if len(g)==0 or e<=s: continue
            m=w[:,s:e].mean(1); rows.append(dict(dyad=int(r['index']),channel=c+1,trial=tr,dist=g.mean(),**{k:m[(f>=a)&(f<b)].mean() for k,(a,b) in B.items()}))
D=pd.DataFrame(rows); D.to_csv(f'{OUT}/wtc_trial_level_CBSI_1Hz.csv',index=False); print(len(D))
