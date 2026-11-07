suppressMessages({library(lme4);library(lmerTest);library(dplyr)})
a<-commandArgs(TRUE);R<-a[1]
d<-read.csv(paste0(R,'FINALFRAMEFORMATRIXRSTUDIOMAHAL.csv'));d<-d[grepl('Chase',d$Event),];v<-read.csv(file.path(a[2],'speed_measure_variants.csv'));d<-merge(d,v,by=c('Dyad','Event'))
cols<-c('Distance.between.self.and.prey','Distance.between.self.and.other','Scaled.self.facing.prey','Scaled.self.facing.other','Lag.Score','Heart.Rate.self','Breathing.Rate.self','Time')
d$orig<-d$Lag.Score;cat('rows',nrow(d),'r(model Lag, coded)',round(cor(d$orig,d$coded),3),'\n')
for(x in c('orig','coded','nowarm','defined','speedr','absdiff')){z<-d;z$Lag.Score<-z[[x]];z<-z%>%mutate(across(all_of(cols),scale))%>%mutate(Dyad=as.factor(Dyad))
 f<-as.formula(paste('Hunting.original ~',paste(cols,collapse='+'),'+(1+Distance.between.self.and.other+Scaled.self.facing.other+Lag.Score|Dyad)+(1+Distance.between.self.and.prey+Scaled.self.facing.prey+Heart.Rate.self+Breathing.Rate.self|Participant)'))
 m<-suppressWarnings(suppressMessages(lmer(f,z,control=lmerControl(optimizer='bobyqa'))));s<-coef(summary(m));cat(sprintf('%-8s speed b=%7.2f t=%6.2f p=%.3f | dist-prey b=%6.2f p=%.3f\n',x,s['Lag.Score','Estimate'],s['Lag.Score','t value'],s['Lag.Score','Pr(>|t|)'],s['Distance.between.self.and.prey','Estimate'],s['Distance.between.self.and.prey','Pr(>|t|)']))}
