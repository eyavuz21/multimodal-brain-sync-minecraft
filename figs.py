import os
import sys,numpy as np,pandas as pd,scipy.io as sio,matplotlib; matplotlib.use('Agg')
import matplotlib.pyplot as plt
from scipy.signal import resample_poly
from PIL import Image,ImageDraw,ImageFont
G,R,OUT=sys.argv[1:4]
plt.rcParams.update({'font.family':'Arial','font.weight':'bold','axes.labelweight':'bold','axes.linewidth':1.6,'xtick.major.width':1.6,'ytick.major.width':1.6,'font.size':16})
FN=lambda s:ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf',s)
# Figure 2A: Fiona's drawing kept, labels re-set larger
im=Image.open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'figure2a_source.png')).convert('RGB'); W,H=im.size; d=ImageDraw.Draw(im)
d.rectangle([0,965,W,H],fill='white'); d.rectangle([0,0,70,50],fill='white')
d.line([60,970,1150,970],fill=(0,0,0),width=3); d.polygon([(1150,970),(1125,960),(1125,980)],fill=(0,0,0))
d.text((14,6),'(A)',font=FN(34),fill='black')
for x,t in [(150,'Time'),(352,'10 s'),(570,'20 s'),(790,'30 s'),(1005,'40 s')]: d.text((x,1000),t,font=FN(32),fill='black',anchor='mm')
d.text((110,1062),'Prey',font=FN(32),fill=(190,30,30)); d.rectangle([195,1058,245,1092],outline=(190,30,30),width=4)
d.text((300,1062),'Self / Other',font=FN(32),fill='black'); d.rectangle([505,1058,555,1092],outline='black',width=4)
im.save(f'{OUT}/Figure2A.png')
# Figure 2B-D
F=pd.read_excel(f'{G}/FINALFRAME Participant Data/FINALFRAME_P01.xlsx')
D=sio.loadmat(f'{G}/GLM Data/P01/Processed Data/preprocessed.mat',squeeze_me=True,struct_as_record=False,variable_names=['Data'])['Data']
Y=resample_poly(D.HbOCBSI,1,25,axis=0)[:,11]
P=pd.read_csv(f'{R}/Study Files/Minecraftanalysis/Analysispipeline/fNIRSanalysispipeline/fNIRSpreprocessing/Biopac/FILTERED_FINALPHYSIOFRAME.csv',usecols=['Dyad','Participant','Time','Event','HRBPM','BRRSP_Rate','SCREDA_Tonic'])
P=P[(P.Dyad==1)&(P.Participant==1)]
print('physio',P.shape,P.Time.min(),P.Time.max())
t0,t1=134,174; h=F[(F.Time-1>=t0)&(F.Time-1<=t1)]
tt=(h.Time.values-1-t0)
rows=[('DirectionToPreyHunt','Heading to prey'),('DirectionToOtherHunt','Heading to other'),('PreyDistHunt','Distance to prey'),('OtherDistHunt','Distance to other')]
_s=pd.to_timedelta(P.Time.astype(str)).dt.total_seconds()-pd.to_timedelta(str(F.Timeoriginal.iloc[0])).total_seconds(); PP=P.assign(Time=_s); PP=PP[(PP.Time>=5)&(PP.Time<=len(F))]
fig,ax0=plt.subplots(10,1,figsize=(11,11.2),gridspec_kw=dict(height_ratios=[1,1,1,1,.55,1,1,1,.55,1.15],hspace=.25,left=.25,right=.97,top=.985,bottom=.065)); [ax0[i].axis('off') for i in (4,8)]; ax=[ax0[i] for i in (0,1,2,3,5,6,7,9)]
def st(a,l,x=None,xl=None):
    a.set_ylabel(l,rotation=0,ha='right',va='center',fontsize=16); a.set_yticks([]); a.spines[['top','right']].set_visible(False)
    if xl: a.set_xlabel(xl,fontsize=17,labelpad=2); a.tick_params(labelsize=15)
    else: a.set_xticks([])
for a,(c,l) in zip(ax[:4],rows): a.plot(tt,h[c].values,color='k',lw=2.6); a.set_xlim(0,39); st(a,l,xl='Time in example Hunt trial (s)' if c=='OtherDistHunt' else None)
for a,(c,l) in zip(ax[4:7],[('HRBPM','Heart rate'),('BRRSP_Rate','Breathing rate'),('SCREDA_Tonic','Skin conductance')]): a.plot(PP.Time,PP[c],color='k',lw=2.2); a.set_xlim(5,PP.Time.max()); st(a,l,xl='Time in session (s)' if c=='SCREDA_Tonic' else None)
ax[7].plot(np.arange(t0-10,t1+10)-t0,Y[t0-10:t1+10],color='k',lw=2.6); ax[7].set_xlim(-10,50); st(ax[7],'fNIRS signal\n(CBSI, channel 12)',xl='Time relative to Hunt onset (s)')
for a,l in zip([ax[0],ax[4],ax[7]],['(B)','(C)','(D)']):
    a.text(-.3,1.0,l,transform=a.transAxes,fontsize=20,va='top')
fig.savefig(f'{OUT}/Figure2BCD.png',dpi=240); plt.close(fig)
# Figure 3 is drawn by figure3_distance.py
