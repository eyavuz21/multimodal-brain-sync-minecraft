import os
import sys,json,numpy as np
from PIL import Image,ImageDraw,ImageFont
XY={1:(1128,803),2:(958,833),3:(754,858),4:(561,838),5:(390,803),6:(1212,668),7:(1041,720),8:(852,773),9:(648,770),10:(474,731),11:(303,683),12:(1124,600),13:(958,657),14:(765,694),15:(569,647),16:(383,606),17:(1033,533),18:(858,585),19:(646,585),20:(474,551),21:(947,475),22:(759,482),23:(558,473)}
FN=lambda s:ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf',s)
src=Image.open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'brain_panel_source.png')).convert('RGB')
def clean_panel():
    # panel crop from published figure, markers erased by inpainting from neighbours
    from scipy import ndimage as ni
    a=np.array(src.crop((90,90,340,350))).astype(float)
    r,g,b=a[...,0],a[...,1],a[...,2]
    m=ni.binary_dilation(((b-r>40)|(r-b>40)|((r>235)&(g>235)&(b>235)&False)),iterations=2)
    for (x,y) in XY.values():
        yy,xx=np.ogrid[:a.shape[0],:a.shape[1]]; m|=((xx-x/6)**2+(yy-y/6)**2)<=9.5**2
    for c in range(3):
        v=a[...,c]; v2=ni.distance_transform_edt(m,return_indices=True)[1]; a[...,c]=ni.gaussian_filter(v[v2[0],v2[1]],1.2)*m+v*~m
    return Image.fromarray(a.astype('uint8')).resize((750,780),Image.LANCZOS)
base=clean_panel()
def draw(sig,path):
    S=3; pw,ph=750,780; lm=120; rm=420; tm=110
    im=Image.new('RGB',(lm+3*pw+rm,tm+2*ph),'white'); d=ImageDraw.Draw(im)
    for j,b in enumerate(['High','Mid','Low']):
        d.text((lm+pw*j+pw/2,50),{'High':'High (0.1-0.2 Hz)','Mid':'Mid (0.03-0.1 Hz)','Low':'Low (0.02-0.03 Hz)'}[b],font=FN(52),fill='black',anchor='mm')
    for i,t in enumerate(['Chase','Follow']):
        d.text((50,tm+ph*i+ph/2),'(%s)'%'AB'[i],font=FN(56),fill='black',anchor='mm')
        d.text((lm+3*pw+rm/2,tm+ph*i+ph/2-10),{'Chase':'Hunt > Chance','Follow':'Follow > Chance'}[t],font=FN(50),fill='black',anchor='mm')
        for j,b in enumerate(['High','Mid','Low']):
            x0,y0=lm+pw*j,tm+ph*i; im.paste(base,(x0,y0)); on=sig.get(t+b,[])
            for c,(x,y) in XY.items():
                cx=x0+x/2; cy=y0+y/2; col=(214,39,40) if c in on else (31,78,200)
                d.ellipse([cx-27,cy-27,cx+27,cy+27],fill=col,outline='white',width=3)
                d.text((cx,cy),str(c),font=FN(32),fill='white',anchor='mm')
    im.save(path)
if __name__=='__main__':
    draw(json.load(open(sys.argv[1])),sys.argv[2])
