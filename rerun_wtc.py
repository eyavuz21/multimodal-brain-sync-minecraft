"""Corrected wavelet coherence rerun. CBSI or HbO, down-sampled to 1 Hz, frequencies in Hz,
trial windows in seconds from the onset files, 1,000 circular time shifts of partner 1."""
import sys,os
os.environ['OMP_NUM_THREADS']='1'
import numpy as np,scipy.io as sio,pandas as pd,multiprocessing as mp
from scipy.signal import resample_poly
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from wtc_python import wcoherence
G=sys.argv[1]; OUT=sys.argv[2]; NIT=int(sys.argv[3]); glm=G+'/GLM Data'
pairs=pd.read_csv(G+'/Wavelet Coherence/pairTable.csv')
def trials(p):
    o=sio.loadmat(f'{glm}/{p}/Logs/Onsets/{p}U_onsets.mat',squeeze_me=True,struct_as_record=False)
    out={}
    for i,k in enumerate(['Follow','Chase']):  # order verified from the names string in each file and FINALFRAME events
        u=np.unique(np.c_[np.atleast_1d(o['onsets'][i]).ravel(),np.atleast_1d(o['durations'][i]).ravel()],axis=0)
        out[k]=u
    return out
def load(p,sig):
    D=sio.loadmat(f'{glm}/{p}/Processed Data/preprocessed.mat',squeeze_me=True,struct_as_record=False,variable_names=['Data'])['Data']
    x=getattr(D,{'CBSI':'HbOCBSI','HbO':'HbO'}[sig])
    return resample_poly(x,1,25,axis=0)
def scramble(x,rng):  # block_time_scramble.m
    n=len(x); b=int(np.floor(.01*n)); s=rng.integers(1+b,n-b+1); y=np.roll(x,s)
    st=max(1,s-b)-1; en=min(s+b,n)
    y[st:s]=np.linspace(1,0,s-st)*y[st:s]; y[s:en]=np.linspace(1,0,en-s)*y[s:en]
    return y
def bands(w,f,T):
    B=[(f>=.02)&(f<.03),(f>=.03)&(f<.1),(f>=.1)&(f<=.2)]; out=[]
    for tt,S in T.items():
        r=[]
        for on,du in S:
            s=int(round(on)); e=min(int(round(on+du))+1,w.shape[1])
            if e>s: r.append(w[:,s:e].mean(1))
        c=np.mean(r,0); out.append((tt,*[float(c[b].mean()) for b in B]))
    return out
def job(a):
    sig,d,ch,p1,p2=a
    x=DATA[sig,p1][:,ch]; y=DATA[sig,p2][:,ch]; n=min(len(x),len(y)); x,y=x[:n].copy(),y[:n].copy(); T=TR[p1]
    rng=np.random.default_rng([sum(map(ord,sig)),d,ch,20261107])
    w,f=wcoherence(x,y,fs=1.0); R=[(sig,d,ch+1,*r) for r in bands(w,f,T)]; N=[]
    for it in range(NIT):
        w,f=wcoherence(scramble(x,rng),y,fs=1.0)
        N+= [(sig,d,ch+1,it+1,*r) for r in bands(w,f,T)]
    return R,N
SIGS=['CBSI','HbO']; DATA={};TR={}
for _,r in pairs.iterrows():
    TR[r.Member1]=trials(r.Member1)
    for p in (r.Member1,r.Member2):
        for s in SIGS: DATA[s,p]=load(p,s)
if __name__=='__main__':
    os.makedirs(OUT,exist_ok=True)
    jobs=[(s,int(r['index']),c,r.Member1,r.Member2) for s in SIGS for _,r in pairs.iterrows() for c in range(25)]
    with mp.get_context('fork').Pool(int(sys.argv[4])) as P: res=[]; [res.append(x) or (len(res)%25==0 and print(len(res),flush=True)) for x in P.imap(job,jobs,chunksize=1)]
    c=['AvgCoherenceLowFreq','AvgCoherenceMidFreq','AvgCoherenceHighFreq']
    R=pd.DataFrame([x for r,_ in res for x in r],columns=['Signal','Dyad','Channel','TrialType']+c)
    N=pd.DataFrame([x for _,r in res for x in r],columns=['Signal','Dyad','Channel','Iteration','TrialType']+c)
    for s in SIGS:
        R[R.Signal==s].drop(columns='Signal').to_csv(f'{OUT}/wtc_real_{s}_1Hz.csv',index=False)
        N[N.Signal==s].drop(columns='Signal').to_csv(f'{OUT}/wtc_null_{s}_1Hz_{NIT}.csv',index=False)
    print('done')
