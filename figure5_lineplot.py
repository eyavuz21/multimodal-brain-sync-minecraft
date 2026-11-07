"""Figure 5: Hunt vs Follow wavelet coherence in channel 20, high band, per dyad."""
import sys,numpy as np,pandas as pd,matplotlib; matplotlib.use('Agg')
import matplotlib.pyplot as plt
from scipy import stats
K,OUT=sys.argv[1:3]
plt.rcParams.update({'font.family':'Arial','font.weight':'bold','axes.labelweight':'bold','axes.linewidth':1.6,'xtick.major.width':1.6,'ytick.major.width':1.6,'font.size':16})
d=pd.read_csv(K+'/Output/wtc_real_CBSI_1Hz.csv');x=d[d.Channel==20].pivot(index='Dyad',columns='TrialType',values='AvgCoherenceHighFreq');H,F=x.Chase.values,x.Follow.values
assert (H>F).all() and abs(stats.ttest_1samp(H-F,0).statistic-5.69)<.01
fig,a=plt.subplots(figsize=(6,5.6),gridspec_kw=dict(left=.17,right=.97,top=.97,bottom=.1))
for h,f in zip(H,F): a.plot([0,1],[h,f],color='#8A8F98',lw=1.8,marker='o',ms=7,mfc='#8A8F98',mec='white',zorder=2)
for i,v in enumerate((H,F)):
    a.errorbar(i+(-.13 if i==0 else .13),v.mean(),yerr=stats.t.ppf(.975,8)*stats.sem(v),color='k',lw=3,capsize=7,capthick=3,marker='o',ms=12,zorder=4)
a.set_xticks([0,1],['Hunt','Follow']);a.set_xlim(-.4,1.4);a.set_ylim(.25,.5);a.set_yticks(np.arange(.25,.51,.05));a.set_ylabel('Wavelet coherence (0.1-0.2 Hz)');a.spines[['top','right']].set_visible(False)
a.text(.5,.494,'t(8) = 5.69, FDR-corrected p = .011',ha='center',va='top',fontsize=15)
fig.savefig(OUT,dpi=240)
