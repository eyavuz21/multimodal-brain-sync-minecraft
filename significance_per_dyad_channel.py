"""Above-chance test as specified by A. Hamilton (email, 12 Jun 2024) and the manuscript Methods: for each dyad and channel,
compare true WTC with the percentile of that dyad and channel's own time-shifted distribution, then require k dyads per channel.
Calibration: apply the same thresholds to each time-shifted dataset as if it were real data."""
import sys,numpy as np,pandas as pd
G=sys.argv[1];K=G+'/Rerun Nov 2026 - CBSI 1Hz/Output/'
np.random.seed(1);nc,nd,ns=25,9,5000;th=np.linspace(.001,.2,60);kn=np.zeros((60,8))
for j,t in enumerate(th):
    c=(np.random.rand(nc*ns,nd)<t).sum(1);kn[j]=np.histogram(c,bins=np.arange(9))[0]
kth=kn/(ns*nc)<.05;AL={k:float(th[np.max(np.where(kth[:,k])[0])]) for k in (3,4,5)};print('monte carlo alpha',{k:round(v,3) for k,v in AL.items()});AL[4]=.18
B={'High':'AvgCoherenceHighFreq','Mid':'AvgCoherenceMidFreq','Low':'AvgCoherenceLowFreq'}
def run(rf,nf,lab,save=None):
    r=pd.read_csv(rf);n=pd.read_csv(nf);print('=====',lab);rows=[];G_T=None;G_t=0
    for tt in ['Chase','Follow']:
        TT=None;tt_n=0
        for b,c in B.items():
            A=n[n.TrialType==tt].pivot_table(index=['Dyad','Channel'],columns='Iteration',values=c).sort_index();v=A.values;ch=A.index.get_level_values('Channel').values
            o=r[r.TrialType==tt].set_index(['Dyad','Channel'])[c].reindex(A.index).values
            for k in (3,4,5):
                w=np.nanquantile(v,1-AL[k],axis=1);hits=pd.Series(o>w).groupby(ch).sum();H=sorted(int(x) for x in hits[hits>=k].index)
                if k==4:
                    P=v>w[:,None];cn=np.array([(pd.Series(P[:,i]).groupby(ch).sum()>=k).sum() for i in range(P.shape[1])])
                    print(f'{tt:6s} {b:4s} k=4 n={len(H):2d} {H} per-channel dyads {[int(hits[x]) for x in H]} null mean {cn.mean():.2f} p95 {np.percentile(cn,95):.0f} p={(cn>=len(H)).mean():.3f}')
                    TT=cn if TT is None else TT+cn;tt_n+=len(H);G_T=cn if G_T is None else G_T+cn;G_t+=len(H)
                    rows+= [(tt,b,x,int(hits[x])) for x in H]
                else: print(f'    {tt:6s} {b:4s} k={k} alpha={AL[k]:.3f} {H}')
        print(tt,'ALL BANDS',tt_n,'null mean %.1f p95 %.0f p=%.3f'%(TT.mean(),np.percentile(TT,95),(TT>=tt_n).mean()))
    print('TOTAL',G_t,'null mean %.1f p=%.3f'%(G_T.mean(),(G_T>=G_t).mean()))
    if save: pd.DataFrame(rows,columns=['TrialType','Band','Channel','DyadsPassing']).to_csv(save,index=False)
run(K+'wtc_real_CBSI_1Hz.csv',K+'wtc_null_CBSI_1Hz_1000.csv','CBSI corrected',K+'wtc_significant_per_dyad_channel_CBSI_1Hz.csv')
run(K+'wtc_real_HbO_1Hz.csv',K+'wtc_null_HbO_1Hz_1000.csv','HbO corrected (for Hugo only)')
run(G+'/Wavelet Coherence/wtc_real_dyads.csv',G+'/Wavelet Coherence/wtc_null_timeshift_1000.csv','Saved published data')
