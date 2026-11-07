"""Figure 4: brain maps for Hunt > Chance, Follow > Chance and Hunt > Follow (CBSI, 1 Hz)."""
import sys
K,OUT=sys.argv[1:3]; sys.path.insert(0,K)
import fig5
from PIL import Image,ImageDraw
S={'A':{'High':[1,3,7,20,21],'Mid':[],'Low':[]},'B':{'High':[],'Mid':[],'Low':[]},'C':{'High':[20],'Mid':[],'Low':[]}}  # red only where the band's channel count beats the time-shifted null (Hunt high, p=.015); C = FDR contrast
L={'A':'Hunt > Chance','B':'Follow > Chance','C':'Hunt > Follow'}
pw,ph=750,780; lm,rm,tm=120,420,110
im=Image.new('RGB',(lm+3*pw+rm,tm+3*ph),'white'); d=ImageDraw.Draw(im); FN=fig5.FN
for j,(b,t) in enumerate([('High','High (0.1-0.2 Hz)'),('Mid','Mid (0.03-0.1 Hz)'),('Low','Low (0.02-0.03 Hz)')]): d.text((lm+pw*j+pw/2,50),t,font=FN(52),fill='black',anchor='mm')
for i,r in enumerate('ABC'):
    d.text((50,tm+ph*i+ph/2),f'({r})',font=FN(56),fill='black',anchor='mm'); d.text((lm+3*pw+rm/2,tm+ph*i+ph/2-10),L[r],font=FN(50),fill='black',anchor='mm')
    for j,b in enumerate(['High','Mid','Low']):
        x0,y0=lm+pw*j,tm+ph*i; im.paste(fig5.base,(x0,y0))
        for c,(x,y) in fig5.XY.items():
            cx=x0+x/2; cy=y0+y/2; col=(214,39,40) if c in S[r][b] else (31,78,200)
            d.ellipse([cx-27,cy-27,cx+27,cy+27],fill=col,outline='white',width=3); d.text((cx,cy),str(c),font=FN(32),fill='white',anchor='mm')
im.save(OUT); print(im.size)
