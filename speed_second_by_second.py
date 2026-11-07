"""Speed similarity as described in the Methods: rolling 5 s correlation of second-by-second path distance changes, averaged per trial.
Windows with no defined correlation (a predator did not move) are excluded rather than filled with zero."""
import sys,pandas as pd,numpy as np,warnings;warnings.filterwarnings('ignore')
R,OUT=sys.argv[1:3]
c=['Dyad','Event','Length of trial','Predator CSlinn99 current X','Predator CSlinn99 current Z','Predator caledonian26 current X','Predator caledonian26 current Z']
d=pd.read_excel(R+'FINALFRAMEEVERYTHINGUSECHECK.xlsx',usecols=c);lim=['Follow 72','Follow 77','Follow 78','Follow 86'];d=d[~(d.Event.isin(lim)&(d['Length of trial']>60))].copy()
d['T']=d.Event.str.extract(r'([a-zA-Z]+)');d['N']=d.Event.str.extract(r'(\d+)').astype(int);d=d.sort_values(['T','N'],kind='stable').reset_index(drop=True);d['NN']=d.groupby('T').N.rank(method='dense').astype(int);d['Event']=d['T']+' '+d.NN.astype(str);rows=[]
for (dy,ev),g in d[d['T']=='Chase'].groupby(['Dyad','Event']):
    a=np.sqrt(g['Predator CSlinn99 current X'].diff()**2+g['Predator CSlinn99 current Z'].diff()**2);b=np.sqrt(g['Predator caledonian26 current X'].diff()**2+g['Predator caledonian26 current Z'].diff()**2)
    r=a.rolling(5).corr(b).replace([np.inf,-np.inf],np.nan);rows.append(dict(Dyad=dy,Event=ev,speed=r.mean(),windows=r.notna().sum(),undefined=r.iloc[5:].isna().mean()))
X=pd.DataFrame(rows);X.to_csv(OUT,index=False);print(len(X),X.speed.isna().sum(),X.describe().round(3).loc[['mean','min','max']])
