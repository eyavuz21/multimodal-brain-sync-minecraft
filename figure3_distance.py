"""Figure 3: distance to prey against time to catch, the 187 observations in the model."""
import sys,pandas as pd,matplotlib; matplotlib.use('Agg')
import matplotlib.pyplot as plt
R,OUT=sys.argv[1:3]
plt.rcParams.update({'font.family':'Arial','font.weight':'bold','axes.labelweight':'bold','axes.linewidth':1.6,'xtick.major.width':1.6,'ytick.major.width':1.6,'font.size':16})
p=pd.read_csv(R+'PREZSCOREFRAMECHASE.csv');a=pd.read_csv(R+'FINALFRAMEFORMATRIXRSTUDIOMAHAL.csv');a=a[a.Event.str.contains('Chase')];k=['Dyad','Participant','Event'];d=p.merge(a[k],on=k);print(len(d),d['Distance between self and prey'].describe().round(1).to_dict(),round(d[['Distance between self and prey','Hunting Success']].corr().iloc[0,1],3))
fig,x=plt.subplots(figsize=(7.2,6.6));x.scatter(d['Distance between self and prey'],d['Hunting Success'],s=52,color='k',alpha=.75,linewidth=0);x.set_ylim(0,63);x.set_xlabel('Distance Between Self and Prey (blocks)',fontsize=19);x.set_ylabel('Time Taken to Catch the Prey (Seconds)',fontsize=19);x.tick_params(labelsize=18);x.spines[['top','right']].set_visible(False);fig.tight_layout();fig.savefig(OUT,dpi=240)
