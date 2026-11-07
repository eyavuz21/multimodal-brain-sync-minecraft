import sys,pandas as pd,numpy as np,warnings;warnings.filterwarnings('ignore')
R=sys.argv[1]  # folder holding the behavioural frames
c=['Dyad','Event','Length of trial','Predator CSlinn99 current X','Predator CSlinn99 current Z','Predator caledonian26 current X','Predator caledonian26 current Z']
d=pd.read_excel(R+'FINALFRAMEEVERYTHINGUSECHECK.xlsx',usecols=c)
lim=['Follow 72','Follow 77','Follow 78','Follow 86'];d=d[~(d.Event.isin(lim)&(d['Length of trial']>60))].copy()
d['T']=d.Event.str.extract(r'([a-zA-Z]+)');d['N']=d.Event.str.extract(r'(\d+)').astype(int);d=d.sort_values(['T','N'],kind='stable').reset_index(drop=True);d['NN']=d.groupby('T').N.rank(method='dense').astype(int);d['Event']=d['T']+' '+d.NN.astype(str)
rows=[]
for (dy,ev),g in d[d['T']=='Chase'].groupby(['Dyad','Event']):
    a=np.sqrt(g['Predator CSlinn99 current X'].diff()**2+g['Predator CSlinn99 current Z'].diff()**2);b=np.sqrt(g['Predator caledonian26 current X'].diff()**2+g['Predator caledonian26 current Z'].diff()**2)
    A,B=a.fillna(0).cumsum(),b.fillna(0).cumsum()
    r=A.rolling(5).corr(B);coded=r.fillna(0).replace([np.inf,-np.inf],np.nan).dropna()
    nowarm=r.iloc[4:].fillna(0).replace([np.inf,-np.inf],np.nan).dropna()
    defined=r.replace([np.inf,-np.inf],np.nan).dropna()
    sp=a.fillna(0).rolling(5).corr(b.fillna(0)).replace([np.inf,-np.inf],np.nan).dropna()
    sd=(a-b).abs().dropna()
    rows.append(dict(Dyad=dy,Event=ev,n=len(g),len=g['Length of trial'].iloc[0],coded=coded.mean(),nowarm=nowarm.mean(),defined=defined.mean(),speedr=sp.mean(),absdiff=sd.mean(),pct_undefined=(r.iloc[4:].isna().mean())))
X=pd.DataFrame(rows);X.to_csv(sys.argv[2]+'/speed_measure_variants.csv',index=False);print(len(X));print(X.describe().round(3).T[['mean','min','max']])
P=pd.read_csv(R+'PREZSCOREFRAMECHASE.csv');lp=[k for k in P.columns if k.replace('.',' ').strip().lower()=='lag score'][0];yp=[k for k in P.columns if 'hunting' in k.lower() and 'success' in k.lower()][0]
Q=P.drop_duplicates(['Dyad','Event'])[['Dyad','Event',lp,yp]].merge(X,on=['Dyad','Event']);print('joined',len(Q))
Q['implied_max']=Q[lp]+Q.coded;print('saved + recomputed: mean %.4f sd %.5f ; r(saved,recomputed) %.4f ; recomputed max %.4f'%(Q.implied_max.mean(),Q.implied_max.std(),np.corrcoef(Q[lp],Q.coded)[0,1],X.coded.max()))
print('correlations with time to catch:');print(Q[[yp,'coded','nowarm','defined','speedr','absdiff','pct_undefined','n']].corr(method='pearson')[yp].round(3))
print('corr coded with trial n',round(np.corrcoef(Q.coded,Q.n)[0,1],3),'nowarm with n',round(np.corrcoef(Q.nowarm,Q.n)[0,1],3))
