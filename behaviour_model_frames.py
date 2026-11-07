"""Rebuilds the behavioural model frame with the Methods speed measure, using the notebook's Mahalanobis outlier code."""
import sys,pandas as pd,numpy as np,scipy.stats as sc
from scipy.stats import chi2
R,K=sys.argv[1:3]
d=pd.read_csv(R+'FINALFRAMEFORMATRIXRSTUDIO.csv');s=pd.read_csv(K+'/Output/speed_second_by_second.csv')
V=['Distance between self and other','Distance between self and prey','Scaled self facing prey','Scaled self facing other','Lag Score','Hunting Success','Heart Rate self','Breathing Rate self']
def mah(f):
    f=f.copy();f['Hunting original']=f['Hunting Success'];f['Hunting Success']=sc.zscore(f['Hunting Success']);X=f[V];m=X-X.mean();M=np.dot(np.dot(m,np.linalg.inv(np.cov(X.values.T))),m.T).diagonal();f['Mahalanobis']=M
    cdf=np.round(chi2.cdf(M,8),1);mv=np.round(M,1);minval=mv[cdf==1.0].min();return f[f.Mahalanobis<=minval],f[f.Mahalanobis>minval],minval
o=mah(d[d.Event.str.contains('Chase')]);print('original lag: start',(d.Event.str.contains('Chase')).sum(),'kept',len(o[0]),'removed',len(o[1]),'cut',o[2])
n=d[d.Event.str.contains('Chase')].merge(s[['Dyad','Event','speed']],on=['Dyad','Event'],how='left');print('rows without speed',n.speed.isna().sum(),n[n.speed.isna()][['Dyad','Event','Hunting Success']].drop_duplicates().values.tolist())
n=n.dropna(subset=['speed']);n['Lag Score']=sc.zscore(n['speed']);k=mah(n);print('new: start',len(n),'kept',len(k[0]),'removed',len(k[1]),'cut',k[2]);print('removed trial lengths',sorted(k[1]['Hunting original'].round(0).tolist())[:30])
print('same rows as original keep?',len(k[0].merge(o[0][['Dyad','Participant','Event']],on=['Dyad','Participant','Event'])))
k[0].to_csv(K+'/Output/behaviour_frame_second_by_second.csv',index=False)
# frame A: original 187 rows
a=pd.read_csv(R+'FINALFRAMEFORMATRIXRSTUDIOMAHAL.csv');a=a[a.Event.str.contains('Chase')].merge(s[['Dyad','Event','speed']],on=['Dyad','Event'],how='left');print('A rows',len(a),'missing speed',a.speed.isna().sum());a.to_csv(K+'/Output/behaviour_frame_same_rows.csv',index=False)
