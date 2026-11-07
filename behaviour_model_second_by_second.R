# Table 2 with the Methods speed measure, on the same 187 observations as the original model (final table saved).
# Sensitivity: outliers recomputed with the new measure (184 rows), and no outlier removal (202 rows). Time is omitted from all three sensitivity
# fits because the Time column in the pre-removal frames on disk does not match the model frame (r = .99 with trial length).
suppressMessages({library(lme4);library(lmerTest);library(dplyr);library(effectsize);library(car)})
K<-commandArgs(TRUE)[1]
run<-function(fn,lab,time=TRUE,save=FALSE){cols<-c('Distance.between.self.and.prey','Distance.between.self.and.other','Scaled.self.facing.prey','Scaled.self.facing.other','Speed','Heart.Rate.self','Breathing.Rate.self',if(time)'Time');d<-read.csv(file.path(K,'Output',fn));d$Speed<-d$speed;d<-d[!is.na(d$speed),];z<-d%>%mutate(across(all_of(cols),~as.numeric(scale(.))))%>%mutate(Dyad=as.factor(Dyad))
 f<-as.formula(paste('Hunting.original ~',paste(cols,collapse='+'),'+(1+Distance.between.self.and.other+Scaled.self.facing.other+Speed|Dyad)+(1+Distance.between.self.and.prey+Scaled.self.facing.prey+Heart.Rate.self+Breathing.Rate.self|Participant)'))
 w<-character();m<-withCallingHandlers(lmer(f,z,control=lmerControl(optimizer='bobyqa')),warning=function(e){w<<-c(w,conditionMessage(e));invokeRestart('muffleWarning')},message=function(e){w<<-c(w,conditionMessage(e));invokeRestart('muffleMessage')})
 s<-coef(summary(m));se<-sqrt(diag(vcov(m)));ef<-suppressWarnings(suppressMessages(cohens_f(m)));F2<-setNames(round(ef$Cohens_f_partial^2,3),ef$Parameter)
 T<-data.frame(var=rownames(s),b=round(s[,1],2),lo=round(fixef(m)-1.96*se,2),hi=round(fixef(m)+1.96*se,2),df=round(s[,3],1),t=round(s[,4],2),p=round(s[,5],3),f2=F2[rownames(s)]);cat('=====',lab,'rows',nrow(z),'participants',length(unique(z$Participant)),'singular',isSingular(m),'warn',length(w),'\n');print(T[T$var%in%c('Distance.between.self.and.prey','Speed'),],row.names=FALSE);if(save){write.csv(T,file.path(K,'Output/table2_second_by_second.csv'),row.names=FALSE);print(T,row.names=FALSE);print(round(max(vif(m)),2))}}
run('behaviour_frame_same_rows.csv','FINAL 187 rows with Time',TRUE,TRUE)
run('behaviour_frame_same_rows.csv','187 rows no Time',FALSE);run('behaviour_frame_second_by_second.csv','outliers recomputed, no Time',FALSE);run('behaviour_frame_all_rows.csv','no outlier removal, no Time',FALSE)
