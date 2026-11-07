# Distance between predators vs INS during Hunt trials, final model agreed with H. Singmann (emails 27-28 Jan 2026):
# per channel and band: Coherence ~ Distance + (1 + Distance | Dyad), one row per trial; FDR across 25 channels within band.
# Across channels: Coherence ~ Distance + (Distance | Dyad) + (Distance | Channel) + (Distance | Trial).
suppressMessages({library(lme4);library(lmerTest)})
args<-commandArgs(TRUE);K<-args[1]
d<-read.csv(file.path(K,'Output/wtc_trial_level_CBSI_1Hz.csv'));d$z<-as.numeric(scale(d$dist));d$tr<-paste(d$dyad,d$trial);d$dyad<-factor(d$dyad)
cat('rows',nrow(d),'dyads',nlevels(d$dyad),'trials per channel',length(unique(d$tr)),'per dyad',paste(table(d[d$channel==1,'dyad']),collapse=','),'\n')
ctl<-lmerControl(optimizer='bobyqa',optCtrl=list(maxfun=2e5),check.conv.singular=.makeCC('ignore',tol=1e-4))
res<-list()
for(b in c('Low','Mid','High')) for(ch in 1:25){g<-d[d$channel==ch,];conv<-NA;w<-character()
 m<-withCallingHandlers(lmer(as.formula(paste(b,'~ z + (1+z|dyad)')),g,control=ctl),warning=function(e){w<<-c(w,conditionMessage(e));invokeRestart('muffleWarning')})
 s<-coef(summary(m));res[[length(res)+1]]<-data.frame(band=b,channel=ch,b=s['z','Estimate'],se=s['z','Std. Error'],df=s['z','df'],t=s['z','t value'],p=s['z','Pr(>|t|)'],singular=isSingular(m),warn=length(w))}
R<-do.call(rbind,res);R$q<-ave(R$p,R$band,FUN=function(p)p.adjust(p,'BH'))
write.csv(R,file.path(K,'Output/wtc_distance_lmm_random_slope_CBSI_1Hz.csv'),row.names=FALSE)
cat('min p / min q by band\n');print(aggregate(cbind(p,q)~band,R,min));cat('singular',sum(R$singular),'of',nrow(R),' warnings',sum(R$warn>0),'\n');print(R[R$p<.05,c('band','channel','b','df','t','p','q','singular')],digits=3)
cat('--- across channels\n')
for(b in c('Low','Mid','High')){w<-character()
 m<-withCallingHandlers(lmer(as.formula(paste(b,'~ z + (z|dyad) + (z|channel) + (z|tr)')),d,control=ctl),warning=function(e){w<<-c(w,conditionMessage(e));invokeRestart('muffleWarning')})
 s<-coef(summary(m));cat(b,'b',round(s['z','Estimate'],4),'df',round(s['z','df'],1),'t',round(s['z','t value'],2),'p',round(s['z','Pr(>|t|)'],3),'singular',isSingular(m),'warn',length(w),'\n')}
