"""Single-brain GLM rerun in Python, following spmfnirsflow.m/spm_fnirs_spm.m: canonical HRF, DCT high-pass 256 s,
HRF temporal smoothing of data and design, OLS, 1 Hz. Regressors built from FINALFRAME 1 Hz frames and unique trial onsets."""
import sys,os,numpy as np,pandas as pd,scipy.io as sio
from scipy.signal import resample_poly
from scipy.stats import gamma,ttest_1samp,ttest_rel
from statsmodels.stats.multitest import multipletests
G,EX,OUT=sys.argv[1:4]; glm=G+'/GLM Data'; os.makedirs(OUT,exist_ok=True)
EXCL=['P07','P08','P14','P15','P19','P22','P26','P31']; PS=[f'P{i:02d}' for i in range(1,33) if f'P{i:02d}' not in EXCL]
def hrf(dt=1.0):
    t=np.arange(0,32+dt,dt); h=gamma.pdf(t,6)-gamma.pdf(t,16)/6; return h/h.sum()
H=hrf(1.0); Hm=hrf(1/16)
def conv(x): return np.convolve(x,H)[:len(x)]
def box(tr,n):
    u=np.zeros(n*16)
    for on,du in tr: u[int(round(on*16)):int(round((on+du)*16))]=1
    return np.convolve(u,Hm)[:n*16][7::16]
def inside(tr,n):
    m=np.zeros(n,bool)
    for on,du in tr: m[int(round(on)):min(int(round(on+du)),n)]=True
    return m
def pm(v,mask):
    o=np.zeros(len(v)); o[mask]=v[mask]-v[mask].mean(); return conv(o)
def fil(X):
    X=X.reshape(len(X),-1); n=len(X); k=int(np.fix(2*n/256+1))
    D=np.cos(np.pi*np.outer(np.arange(n)+.5,np.arange(1,k))/n)*np.sqrt(2/n)
    X=X-D@(D.T@X); return np.apply_along_axis(lambda a:np.convolve(a,H,mode='same'),0,X)
def trials(p):
    o=sio.loadmat(f'{glm}/{p}/Logs/Onsets/{p}U_onsets.mat',squeeze_me=True,struct_as_record=False)
    return {k:np.unique(np.c_[np.atleast_1d(o['onsets'][i]).ravel(),np.atleast_1d(o['durations'][i]).ravel()],axis=0) for i,k in enumerate(['Follow','Hunt'])}
import ast; ex=sio.loadmat(EX,squeeze_me=True)["Excludechannels"]; EXD={str(r[0]):ast.literal_eval(str(r[1])) for r in ex}
rows=[]
for sig,field in [('CBSI','HbOCBSI'),('HbO','HbO')]:
  for p in PS:
    D=sio.loadmat(f'{glm}/{p}/Processed Data/preprocessed.mat',squeeze_me=True,struct_as_record=False,variable_names=['Data'])['Data']
    Y=resample_poly(getattr(D,field),1,25,axis=0); n=len(Y)
    F=pd.read_excel(f'{G}/FINALFRAME Participant Data/FINALFRAME_{p}.xlsx'); T=trials(p)
    def col(c):
        v=np.zeros(n); t=(F.Time.values-1).astype(int); ok=t<n; v[t[ok]]=np.nan_to_num(F[c].values[ok].astype(float)); return v
    mH,mF=inside(T['Hunt'],n),inside(T['Follow'],n); mA=mH|mF
    DPH,DPF,DOH,DOF,RPH,RPF,ROH,ROF=[col(c) for c in ['DirectionToPreyHunt','DirectionToPreyFollow','DirectionToOtherHunt','DirectionToOtherFollow','PreyDistHunt','PreyDistFollow','OtherDistHunt','OtherDistFollow']]
    ev=F.Event.astype(str).str.contains('in-between',case=False); bt=np.zeros(n); t=(F.Time.values-1).astype(int); bt[t[(t<n)&ev.values]]=1
    C=[('HR',col('HRBPM')),('BR',col('BRRSPRate')),('Between',conv(bt)),('Time',np.arange(n)/n)]
    bH,bF,bA=box(T['Hunt'],n),box(T['Follow'],n),box(np.r_[T['Hunt'],T['Follow']],n)
    DM={'DM1':[('Follow',bF),('Hunt',bH),('DistPreyHunt',pm(RPH,mH)),('DistPreyFollow',pm(RPF,mF)),('DirPreyHunt',pm(DPH,mH)),('DirPreyFollow',pm(DPF,mF))],
        'DM2':[('Follow',bF),('Hunt',bH)],
        'DM3':[('Follow',bF),('Hunt',bH),('DirPreyHunt',pm(DPH,mH)),('DirPreyFollow',pm(DPF,mF)),('DirOtherHunt',pm(DOH,mH)),('DirOtherFollow',pm(DOF,mF))],
        'DM4':[('Follow',bF),('Hunt',bH),('DistPreyHunt',pm(RPH,mH)),('DistPreyFollow',pm(RPF,mF)),('DistOtherHunt',pm(ROH,mH)),('DistOtherFollow',pm(ROF,mF))],
        'DM5':[('Follow',bF),('Hunt',bH),('InterHunt',pm(DPH*RPH,mH)),('InterFollow',pm(DPF*RPF,mF))],
        'COMB':[('Trials',bA),('DirPrey',pm(DPH+DPF,mA)),('DirOther',pm(DOH+DOF,mA)),('DistPrey',pm(RPH+RPF,mA)),('DistOther',pm(ROH+ROF,mA))]}
    bad=[c-1 for c in EXD.get(p,[])]
    for dm,R in DM.items():
        names=[a for a,_ in R]+[a for a,_ in C]+['const']
        X=np.c_[np.array([b for _,b in R]).T,np.array([b for _,b in C]).T,np.ones(n)]
        keep=X.std(0)>0; keep[-1]=True
        KX=fil(X[:,keep]); KX[:,-1]=1 if False else KX[:,-1]
        B=np.linalg.pinv(KX)@fil(np.nan_to_num(Y)); full=np.full((X.shape[1],25),np.nan); full[keep]=B[:]
        if os.environ.get("APPLY_EXCL"): full[:,bad]=np.nan
        for i,nm in enumerate(names):
            for c in range(25): rows.append((sig,p,dm,nm,c+1,full[i,c]))
df=pd.DataFrame(rows,columns=['Signal','P','DM','Reg','Channel','Beta']); df.to_csv(f'{OUT}/glm_betas.csv',index=False)
res=[]
def rec(sig,dm,con,g):
    t,pv=ttest_1samp(g,0,axis=0,nan_policy='omit'); t=np.asarray(t);pv=np.asarray(pv);ok=~np.isnan(pv); q=np.full(25,np.nan); q[ok]=multipletests(pv[ok],method='fdr_bh')[1]
    for c in range(25): res.append((sig,dm,con,c+1,g.iloc[:,c].notna().sum(),t[c],pv[c],q[c]))
for (sig,dm),g in df.groupby(['Signal','DM']):
    W=g.pivot_table(index=['P','Reg'],columns='Channel',values='Beta',dropna=False)
    regs=g.Reg.unique()
    for r in regs:
        if r in('const','HR','BR','Between','Time'): continue
        rec(sig,dm,r,W.xs(r,level='Reg'))
    for a,b in [('Hunt','Follow'),('DistPreyHunt','DistPreyFollow'),('DirPreyHunt','DirPreyFollow'),('DirOtherHunt','DirOtherFollow'),('DistOtherHunt','DistOtherFollow'),('InterHunt','InterFollow')]:
        if a in regs: rec(sig,dm,a+'>'+b.replace(a[:-4],'') ,W.xs(a,level='Reg')-W.xs(b,level='Reg'))
R=pd.DataFrame(res,columns=['Signal','DM','Contrast','Channel','N','t','p','q']); R.to_csv(f'{OUT}/glm_stats.csv',index=False)
for sig in ['CBSI','HbO']:
    s=R[R.Signal==sig]; print(sig,'FDR q<.05:',s[s.q<.05][['DM','Contrast','Channel','t','p','q']].round(4).to_string(index=False) if (s.q<.05).any() else 'none')
    for dm,con in [('COMB','DistPrey'),('COMB','DirPrey'),('COMB','DirOther'),('DM1','DirPreyFollow'),('DM1','DistPreyHunt'),('DM1','DirPreyHunt')]:
        x=s[(s.DM==dm)&(s.Contrast==con)&(s.p<.05)]; print(' ',dm,con,[(int(c),round(float(t),2),round(float(p),3)) for c,t,p in zip(x.Channel,x.t,x.p)])
print(R[(R.Signal=='CBSI')&(R.DM=='DM2')].groupby('Contrast').p.min())
# HbO validation against saved BETAVALUES1403 distance
