"""Python port of MATLAB wcoherence (analytic Morlet, 12 voices per octave)."""
import numpy as np
from scipy import signal
W0=6.0
def _scales(n,dt,nv=12):
    no=int(np.floor(np.log2(n)))-1
    s0=2*dt
    return s0*2.0**(np.arange(0,no*nv+1)/nv)
def _cwt(x,scales,dt):
    n=len(x); pad=int(np.ceil(np.log2(n)))+1
    N=2**pad
    # symmetric padding as in MATLAB's cwt-style extension
    k=np.arange(1,N//2+1)*2*np.pi/(N*dt); om=np.r_[0,k,-k[:(N-1)//2][::-1]][:N]
    X=np.fft.fft(x-np.mean(x),N)
    psi=np.sqrt(2*np.pi*scales[:,None]/dt)*np.pi**-0.25*np.exp(-0.5*(scales[:,None]*om-W0)**2)*(om>0)
    return np.fft.ifft(X*psi,axis=1)[:,:n]
def _smooth(c,scales,dt,ns):
    n=c.shape[1]; N=2**int(np.ceil(np.log2(n))+1)
    om=np.fft.fftfreq(N,dt)*2*np.pi
    F=np.fft.fft(c,N,axis=1)*np.exp(-0.5*(scales[:,None]*om)**2)
    s=np.fft.ifft(F,axis=1)[:,:n]
    if ns>1:
        kern=np.ones(ns)/ns
        s=signal.fftconvolve(s,kern[:,None],mode='same',axes=0)
    return s
def wcoherence(x,y,fs=1.0,nv=12,ns=None):
    dt=1.0/fs; n=len(x); sc=_scales(n,dt,nv); ns=ns or nv//2
    cx=_cwt(np.asarray(x,float),sc,dt); cy=_cwt(np.asarray(y,float),sc,dt)
    inv=(1/sc)[:,None]
    sxy=_smooth(inv*cx*np.conj(cy),sc,dt,ns); sxx=_smooth(inv*np.abs(cx)**2,sc,dt,ns); syy=_smooth(inv*np.abs(cy)**2,sc,dt,ns)
    coh=np.abs(sxy)**2/np.maximum(np.abs(sxx)*np.abs(syy),1e-300)
    f=W0/(2*np.pi*sc)
    return np.clip(coh,0,1),f
