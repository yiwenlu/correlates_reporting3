cat('start plotting ...\n')

# sensitivity analyses parameters
s2="85%"; s1="15%" # these two reference quantiles are used in the next two blocks of code
RRud=RReu=2
bias.factor=bias.factor(RRud, RReu)
    
report.ve.levels=c(.65,.9,.95)
digits.risk=4


###################################################################################################
# marginalized risk curves for continuous markers
    
for (eq.geq in 1:2) {  # 1 conditional on s,   2 is conditional on S>=s
for (w.wo.plac in 2:2) { # 1 with placebo lines, 2 without placebo lines. Implementation-wise, the main difference is in ylim
# eq.geq=1; w.wo.plac=2; a=all.markers[1]
    if(verbose) myprint(eq.geq, w.wo.plac)
  
    risks.all=get("risks.all."%.%eq.geq)
    
    if (eq.geq==2) {
        # when eq.geq, later values in prob may be wildly large due to lack of samples
        ylim=range(sapply(risks.all, function(x) x$prob[1]), na.rm=T)
    } else {
        ylim=range(sapply(risks.all, function(x) x$prob), na.rm=T)
    }
    ylim=range(ylim, prev.naive, prev.nnaive, 0)
    if(verbose) myprint(ylim)
    lwd=2
     
    for (a in all.markers) {        
      assay=marker.name.to.assay(a)
      mypdf(oma=c(0,0,0,0), onefile=F, file=paste0(save.results.to, a, "_marginalized_risks", ifelse(eq.geq==1,"_eq","_geq"), 
                                                   ifelse(w.wo.plac==1,"","_woplacebo")), mfrow=.mfrow)
        par(las=1, cex.axis=0.9, cex.lab=1)# axis label orientation
        risks=risks.all[[a]]
        # risks=risks.all[[match(a, all.markers)]]
        is.delta=startsWith(a,"Delta")
        
        ncases=sapply(risks$marker, function(s) sum(dat.ph1$yy[dat.ph1[[a]]>=s], na.rm=T))
        
        if (!is.delta) xlim=get.xlim(dat.ph1, a) else xlim=range(dat.ph1[[a]], na.rm=T)
        shown=risks$marker>=ifelse(study_name=="COVE",log10(10),wtd.quantile(dat.ph1[[a]], dat.ph1$wt, 2.5/100)) & 
              risks$marker<=wtd.quantile(dat.ph1[[a]], dat.ph1$wt, 1-2.5/100)
        plot(risks$marker[shown], risks$prob[shown], 
            xlab=assay_labels_short[assay]%.%ifelse(eq.geq==1," (=s)"," (>=s)"), 
            xlim=xlim, lwd=lwd, ylim=ylim, 
            ylab=paste0("Probability* of ",config$txt.endpoint," by ", tfinal.tpeak, " days post ", config$peak_visit, " Visit"), 
            type="n", main=paste0(all.markers.labels[a]), xaxt="n")
        draw.x.axis.cor(xlim, lloxs[assay], if(is.delta) "delta" else llox_labels[assay])
            
        # prevelance lines
        # abline(h=prev.plac, col="gray", lty=c(1,3,3), lwd=lwd)
        
        # risks
        if (eq.geq==1) {
            abline(h=overall.risks[[iNaive]], col="gray", lty=c(1,3,3), lwd=lwd)
            lines(risks$marker[shown], risks$prob[shown], lwd=lwd)
            lines(risks$marker[shown], risks$lb[shown],   lwd=lwd, lty=3)
            lines(risks$marker[shown], risks$ub[shown],   lwd=lwd, lty=3)    
            img.dat=cbind(risks$marker[shown], risks$prob[shown], risks$lb[shown], risks$ub[shown])
        } else {
            abline(h=overall.risks[[iNaive]][1], col="gray", lty=c(1), lwd=lwd)
            lines(risks$marker[ncases>=5], risks$prob[ncases>=5], lwd=lwd)
            lines(risks$marker[ncases>=5], risks$lb[ncases>=5],   lwd=lwd, lty=3)
            lines(risks$marker[ncases>=5], risks$ub[ncases>=5],   lwd=lwd, lty=3)    
            img.dat=cbind(risks$marker[ncases>=5], risks$prob[ncases>=5], risks$lb[ncases>=5], risks$ub[ncases>=5])
        }
        
        # save to satisfy some journal requirements
        if(w.wo.plac==1) mywrite.csv(img.dat, file=paste0(save.results.to, a, "_risk_curves",ifelse(eq.geq==1,"_eq","_geq")))    
    
        # text overall risks
        if (w.wo.plac==1) {
            # text(x=par("usr")[2]-diff(par("usr")[1:2])/3.5, y=prev.plac[1]+(prev.plac[1]-prev.plac[2])/2, "placebo overall "%.%formatDouble(prev.plac[1],3,remove.leading0=F))        
            text(x=par("usr")[2]-diff(par("usr")[1:2])/3.5, y=overall.risks[[iNaive]][1]+(prev.plac[1]-prev.plac[2])/2, "vaccine overall "%.%formatDouble(overall.risks[[iNaive]][1],3,remove.leading0=F))
        } else {
            # text(x=par("usr")[2]-diff(par("usr")[1:2])/3.5, y=par("usr")[4]-diff(par("usr")[3:4])/20,     "placebo overall "%.%formatDouble(prev.plac[1],3,remove.leading0=F))
            text(x=par("usr")[2]-diff(par("usr")[1:2])/3.5, y=overall.risks[[iNaive]][1]-(overall.risks[[iNaive]][1]-overall.risks[[iNaive]][2])/4, "vaccine overall "%.%formatDouble(overall.risks[[iNaive]][1],3,remove.leading0=F))
        }
        
        # add histogram
        par(new=TRUE) 
        col <- c(col2rgb("olivedrab3")) # orange, darkgoldenrod2
        col <- rgb(col[1], col[2], col[3], alpha=255*0.4, maxColorValue=255)
        tmp.x=dat.ph1[[a]][dat.ph1$ph2]
        tmp.w=dat.ph1$wt[dat.ph1$ph2]
        tmp=get.marker.histogram(tmp.x, tmp.w, attr(config,"config"))
        if (any(is.nan(tmp$density))) tmp=hist(tmp.x, plot=F)
        # plot
        plot(tmp,col=col,axes=F,labels=F,main="",xlab="",ylab="",border=0,freq=F, xlim=xlim, ylim=c(0,max(tmp$density*1.25)))
        #axis(side=4, at=axTicks(side=4)[1:5])
        #mtext("Density", side=4, las=0, line=2, cex=1, at=.3)  
        #mylegend(x=6, fill=col, border=col, legend="Vaccine Group", bty="n", cex=0.7)      
    #mtext(toTitleCase(study_name), side = 1, line = 0, outer = T, at = NA, adj = NA, padj = NA, cex = NA, col = NA, font = NA)
    
    dev.off()    
    } # end assays
    
}
}


# show the results at select assay values
risks.all=get("risks.all.1") 
for (a in all.markers) {
  assay=marker.name.to.assay(a)
  risks=risks.all[[a]]
  # risks=risks.all[[match(a, all.markers)]]
  table.order=which(names(risks$marker) %in% c(" 2.5%", " 5.0%", "95.0%", "97.5%")); table.order=c(setdiff(1:length(risks$marker), table.order), table.order)
  tmp=10**risks$marker[table.order]
  tmp=ifelse(tmp<100, signif(tmp,3), round(tmp))
  out=with(risks, cbind("s"=tmp, "Estimate"=paste0(formatDouble(prob[table.order],digits.risk), " (", formatDouble(lb[table.order],digits.risk), ",", formatDouble(ub[table.order],digits.risk), ")")))
  while (nrow(out)%%4!=0) out=rbind(out, c("s"="", "Estimate"=""))
  tab=cbind(out[1:(nrow(out)/4), ], out[1:(nrow(out)/4)+(nrow(out)/4), ], out[1:(nrow(out)/4)+(nrow(out)/4*2), ], out[1:(nrow(out)/4)+(nrow(out)/4*3), ])
  mytex(tab, file.name=paste0(a, "_marginalized_risks_eq"), align="c", include.colnames = T, save2input.only=T, input.foldername=save.results.to, include.rownames = F,
      longtable=T, caption.placement = "top", label=paste0("tab marginalized_risks_eq ", COR), caption=paste0("Marginalized cumulative risk by Day ",tfinal.tpeak," as functions of ",
                                                                                                              config$peak_visit, " ", assay_labels_short[assay], " (=s) among baseline negative vaccine recipients with 95\\% bootstrap point-wise confidence intervals (",
          ncol(risks.all[[1]]$boot)," replicates).")
      #, col.headers=paste0("\\hline\n", concatList(paste0("\\multicolumn{2}{c}{", labels.axis[1,], "}"), "&"), "\\\\\n")
      )
}




# ###################################################################################################
# # controlled VE curves for continuous markers
#     
# # 1 conditional on s
# # 2 conditional on S>=s
# # 3 same as 1 except that no sens curve is shown
# # 4 same as 3 except that y axis on -log(1-) scale
# for (eq.geq in 1:4) {  
# # eq.geq=4; a=all.markers[1]
#     
#     outs=lapply (all.markers, function(a) {        
#         is.delta=startsWith(a,"Delta")
#         assay=marker.name.to.assay(a)
#         
#         tmp.1=ifelse(eq.geq==1,"_eq",ifelse(eq.geq==2,"_geq","_eq_manus")); if(eq.geq==4) tmp.1=4
#         
#         mypdf(onefile=F, file=paste0(save.results.to, a, "_controlled_ve_curves",tmp.1), mfrow=.mfrow, oma=c(0,0,0,0))
#  
#             lwd=2.5
#             par(las=1, cex.axis=0.9, cex.lab=1)# axis label orientation
#             
#             # load risks
#             risks=get("risks.all."%.%ifelse(eq.geq==2,2,1))[[a]]   
#             table.order=which(names(risks$marker) %in% c(" 2.5%", " 5.0%", "95.0%", "97.5%")); table.order=c(setdiff(1:length(risks$marker), table.order), table.order)
#         
#             #xlim=quantile(dat.ph1[["Day"%.%tpeak%.%a]],if(eq.geq==1) c(.025,.975) else c(0,.95),na.rm=T)
#             if (!is.delta) xlim=get.xlim(dat.ph1, a) else xlim=range(dat.ph1[[a]], na.rm=T)            
#             
#             # compute Bias as a vector, which is a function of s
#             # choose a reference marker value based on matching the overall risk
#             which=which.min(abs(risks$prob-overall.risks[[iNaive]][1]))
#             s.ref=risks$marker[which]
#             Bias=controlled.risk.bias.factor(ss=risks$marker, s.cent=s.ref, s1=risks$marker[s1], s2=risks$marker[s2], RRud) 
#             if (is.nan(Bias[1])) Bias=rep(1,length(Bias))
#         
#             if (eq.geq==2) {
#                 if (study_name %in% c("COVE", "MockCOVE")) {
#                     ylim=c(0.8,1)
#                 } else if (study_name %in% c("ENSEMBLE", "MockENSEMBLE")) {
#                     ylim=c(0.5,1)
#                 } else if (study_name %in% c("HVTN705")) {
#                     ylim=c(-1,1)
#                 } else {
#                     ylim=c(0,1)
#                 }
#             } else if (eq.geq==4) {
#                 ylim=-log(1-ve_ylim_log)
#             } else {
#                 ylim=config$ve_ylim
#             }
#             
#             ncases=sapply(risks$marker, function(s) sum(dat.ph1$yy[dat.ph1[[a]]>=s], na.rm=T))        
#             .subset=if(eq.geq!=2) {
#                 risks$marker>=ifelse(study_name=="COVE",log10(10),wtd.quantile(dat.ph1[[a]], dat.ph1$wt, 2.5/100)) & 
#                 risks$marker<=wtd.quantile(dat.ph1[[a]], dat.ph1$wt, 1-2.5/100)
#             } else ncases>=5
#             
#             
#             # CVE with sensitivity analysis
#             est = 1 - risks$prob*Bias/res.plac.cont["est"]
#             boot = 1 - t( t(risks$boot*Bias)/res.plac.cont[2:(1+ncol(risks$boot))] ) # res.plac.cont may have more bootstrap replicates than risks$boot
#             ci.band=apply(boot, 1, function (x) quantile(x, c(.025,.975), na.rm=T))
#             # for table
#             tmp=10**risks$marker[table.order];     tmp=ifelse(tmp<100, signif(tmp,3), round(tmp))
#             ret=cbind("s"=tmp, "Estimate"=paste0(formatDouble(est[table.order],digits.risk), " (", formatDouble(ci.band[1,table.order],digits.risk), ",", formatDouble(ci.band[2,table.order],digits.risk), ")"))
#                         
#             # draw CVE curve with sensitivity analysis
#             mymatplot(risks$marker[.subset], t(rbind(est, ci.band))[.subset,], type="l", lty=c(1,2,2), 
#                 col=ifelse(eq.geq==1,"red","white"), # white is no plot
#                 lwd=lwd, make.legend=F, 
#                 ylab=paste0("Controlled VE against ",config$txt.endpoint," by ", tfinal.tpeak, " days post Day ", tpeak1, " Visit"), 
#                 main=paste0(assay_labels[assay]),
#                 xlab=assay_labels_short[assay]%.%ifelse(eq.geq!=2," (=s)"," (>=s)"), 
#                 ylim=ylim, xlim=xlim, yaxt="n", xaxt="n", draw.x.axis=F)
#             # y axis labels
#             if (eq.geq!=4) {
#                 yat=seq(-1,1,by=.1)
#                 axis(side=2,at=yat,labels=(yat*100)%.%"%")            
#             } else {
#                 yat=c(seq(-2,0,by=.5),seq(0,.90,by=.1),.95)
#                 axis(side=2,at=-log(1-yat),labels=(yat*100)%.%"%")            
#             }
#             # x axis
#             draw.x.axis.cor(xlim, lloxs[assay], if(is.delta) "delta" else llox_labels[assay])
#             
#             img.dat=cbind(risks$marker[.subset], t(rbind(est, ci.band))[.subset,])
#         
#             # add overall CVE horizontal line
#             abline(h=if(eq.geq==4) -log(1-overall.ve) else overall.ve, col="gray", lwd=2, lty=c(1,3,3))
#             #text(x=par("usr")[1], y=overall.ve[1]+(overall.ve[1]-overall.ve[2])/2,     "overall VE "%.%round(overall.ve[1]*100)%.%"%", adj=0)
#         
#                 
#             # add CVE curve
#             est = 1 - risks$prob/res.plac.cont["est"]; boot = 1 - t( t(risks$boot)/res.plac.cont[2:(1+ncol(risks$boot))] )
#             #est = 1 - (risks$prob+0.00227)/res.plac.cont["est"]; boot = 1 - t( t(risks$boot+0.00227)/res.plac.cont[2:(1+ncol(risks$boot))] )
#             ci.band=apply(boot, 1, function (x) quantile(x, c(.025,.975), na.rm=T))  
#             y= t(rbind(est, ci.band))[.subset,]
#             if(eq.geq==4) y=-log(1-y)
#             mymatplot(risks$marker[.subset], y, type="l", lty=c(1,2,2), col=if(eq.geq!=1) "black" else "pink", lwd=lwd, make.legend=F, add=T)
# #            if (config$is_ows_trial) {
# #                # find marker values under specific VE
# #                tmpind=sapply(report.ve.levels, function (x) ifelse (x>min(est)-0.01 & x<max(est)+0.01, which.min(abs(est-x)), NA))
# #                tmp=10**risks$marker[tmpind]; tmp=c(round(tmp[1],1), round(tmp[-1]))
# #                ret=rbind(ret, cbind("s"=tmp, "Estimate"=paste0(formatDouble(est[tmpind],digits.risk), " (", formatDouble(ci.band[1,tmpind],digits.risk), ",", formatDouble(ci.band[2,tmpind],digits.risk), ")")))            
# #            }
#     
#             img.dat=cbind(img.dat, y)
#             mywrite.csv(img.dat, file=paste0(save.results.to, a, "_controlled_ve_curves",tmp.1))    
#             
#             
#             # legend
#             tmp=formatDouble(overall.ve*100,1)%.%"%"        
#             legend.x=9; if(eq.geq %in% c(1,3) & config$low_efficacy) legend.x=1; if(eq.geq==4) legend.x=1
#             mylegend(x=legend.x,legend=c(
#                     paste0("Overall VE ",tmp[1]," (",tmp[2],", ",tmp[3],")"), 
#                     "Controlled VE",
#                     if(eq.geq==1) "Controlled VE Sens. Analysis"), 
#                 col=c("gray", if(eq.geq==1) "pink" else "black", if(eq.geq==1) "red"), 
#                 lty=1, lwd=2, cex=.8)
#         
#             
# #            # add segments if needed
# #            newx=log10(c(54,247,563))
# #            fit.tmp=try(svycoxph(update(form.0, as.formula(paste0("~.+",a))), design=twophase(id=list(~1,~1), strata=list(NULL,~Wstratum), subset=~ph2, data=dat.ph1)))        
# #            out=marginalized.risk(fit.tmp, a, dat.ph1.ph2, t=tfinal.tpeak, ss=newx, weights=dat.ph1.ph2$wt, categorical.s=F)
# #            out=-log(out/res.plac.cont["est"])
# #            segments(newx, -1, newx, out, col=c("darkgreen","darkorchid3","deepskyblue3"), lwd=2)
# #            segments(rep(-2,3),out, newx,out, col=c("darkgreen","darkorchid3","deepskyblue3"), lwd=2)
# 
#         
#             # add histogram
#             par(new=TRUE) 
#             col <- c(col2rgb("olivedrab3")) # orange, darkgoldenrod2
#             col <- rgb(col[1], col[2], col[3], alpha=255*0.4, maxColorValue=255)            
#             tmp.x=dat.ph1[[a]][dat.ph1$ph2]
#             tmp.w=dat.ph1$wt[dat.ph1$ph2]
#             tmp=get.marker.histogram(tmp.x, tmp.w, attr(config,"config"))
#             if (is.nan(tmp$density[1])) tmp=hist(tmp.x, plot=F)
#             if(eq.geq==4) tmp$density=tmp$density*3
#             plot(tmp,col=col,axes=F,labels=F,main="",xlab="",ylab="",border=0,freq=F,xlim=xlim, ylim=c(0,max(tmp$density*1.25))) 
#             
#     
#         dev.off()    
#             
#         ret        
#     })
#     
#     
#     if(eq.geq==1) {
#         # show the results at select assay values
#         for (a in all.markers) { 
#           assay=marker.name.to.assay(a)
#           out=outs[[a]]
#             while (nrow(out)%%4!=0) out=rbind(out, c("s"="", "Estimate"=""))
#             tab=cbind(out[1:(nrow(out)/4), ], out[1:(nrow(out)/4)+(nrow(out)/4), ], out[1:(nrow(out)/4)+(nrow(out)/4*2), ], out[1:(nrow(out)/4)+(nrow(out)/4*3), ])        
#             mytex(tab, file.name=paste0(a, "_controlled_ve_sens_eq"), align="c", include.colnames = T, save2input.only=T, input.foldername=save.results.to, include.rownames = F,
#                 longtable=T, caption.placement = "top", label=paste0("tab controlled_ve_sens_eq ", COR), caption=paste0("Controlled VE with sensitivity analysis as functions of Day ",
#                     tpeak," ", assay_labels_short[assay], " (=s) among baseline negative vaccine recipients with 95\\% bootstrap point-wise confidence intervals (",
#                     ncol(risks.all[[1]]$boot)," replicates)."
#                     )
#                 #, col.headers=paste0("\\hline\n", concatList(paste0("\\multicolumn{2}{c}{", labels.axis[1,], "}"), "&"), "\\\\\n")
#                 )
#         }
#     }
#     
# } # end for eq.geq
# 
# 
# # show tables of controlled ve without sensitivity at select assay values
# digits.risk=4
# risks.all=get("risks.all.1")
# for(a in all.markers) {        
#   assay=marker.name.to.assay(a)
#   risks=risks.all[[a]]
#     table.order=which(names(risks$marker) %in% c(" 2.5%", " 5.0%", "95.0%", "97.5%")); table.order=c(setdiff(1:length(risks$marker), table.order), table.order)
#     
#     est = 1 - risks$prob/res.plac.cont["est"]
#     boot = 1 - t( t(risks$boot)/res.plac.cont[2:(1+ncol(risks$boot))] )                         
#     ci.band=apply(boot, 1, function (x) quantile(x, c(.025,.975), na.rm=T))        
#     
#     tmp=10**risks$marker[table.order];     tmp=ifelse(tmp<100, signif(tmp,3), round(tmp))
#     ret = cbind("s"=tmp, "Estimate"=paste0(formatDouble(est[table.order],digits.risk), " (", formatDouble(ci.band[1,table.order],digits.risk), ",", formatDouble(ci.band[2,table.order],digits.risk), ")"))
#     
# #    if (config$is_ows_trial) {
# #        # find marker values under specific VE
# #        tmpind=sapply(report.ve.levels, function (x) ifelse (x>min(est)-0.01 & x<max(est)+0.01, which.min(abs(est-x)), NA))
# #        tmp=10**risks$marker[tmpind]; tmp=c(round(tmp[1],1), round(tmp[-1]))
# #        out=rbind(ret, cbind("s"=tmp, "Estimate"=paste0(formatDouble(est[tmpind],digits.risk), " (", formatDouble(ci.band[1,tmpind],digits.risk), ",", formatDouble(ci.band[2,tmpind],digits.risk), ")")))
# #    } 
#         
#     while (nrow(ret)%%4!=0) ret=rbind(ret, c("s"="", "Estimate"=""))
#     tab=cbind(ret[1:(nrow(ret)/4), ], ret[1:(nrow(ret)/4)+(nrow(ret)/4), ], ret[1:(nrow(ret)/4)+(nrow(ret)/4*2), ], ret[1:(nrow(ret)/4)+(nrow(ret)/4*3), ])
#     
#     mytex(tab, file.name=paste0(a, "_controlled_ve_eq"), align="c", include.colnames = T, save2input.only=T, input.foldername=save.results.to, include.rownames = F,
#         longtable=T, caption.placement = "top", label=paste0("tab controlled_ve_eq ", COR), caption=paste0("Controlled VE as functions of Day ",
#             tpeak," ", assay_labels_short[assay], " (=s) among baseline negative vaccine recipients with 95\\% bootstrap point-wise confidence intervals (",
#             ncol(risks.all[[1]]$boot)," replicates). ", "Overall cumulative incidence from ", tpeaklag, " to ",tfinal.tpeak," days post Day ",tpeak1," was ",
#             formatDouble(overall.risks[[iNaive]][1], 3, remove.leading0=F)," in vaccine recipients compared to ",
#             formatDouble(prev.plac[1], 3, remove.leading0=F)," in placebo recipients, with cumulative vaccine efficacy ",
#             formatDouble(overall.ve[1]*100,1),"\\% (95\\% CI ",formatDouble(overall.ve[2]*100,1)," to ",formatDouble(overall.ve[3]*100,1),"\\%).")
#         #, col.headers=paste0("\\hline\n", concatList(paste0("\\multicolumn{2}{c}{", labels.axis[1,], "}"), "&"), "\\\\\n")
#         )
#     
# }


###################################################################################################
# trichotomized markers, marginalized risk and controlled risk table
    
res=sapply (all.markers, function(a) {        
    risks=risks.all.3[[a]]
    # risks=risks.all.3[[match(a, all.markers)]]
    with(risks, c(prob[3]/prob[1], quantile(boot[3,]/boot[1,], c(.025,.975), na.rm=T)))
})
#    
tab=sapply (all.markers, function(a) {
    paste0(
        assay_labels_short[marker.name.to.assay(a)], "&",
        # marginal RR and ci
        formatDouble(res[1,a],2,remove.leading0=F), "&", formatDouble(res[2,a],2,remove.leading0=F), "--", ifelse(res[3,a]>1000,"Inf",formatDouble(res[3,a],2,remove.leading0=F))
        , "&" ,
        # causal RR and ci
        formatDouble(res[1,a]*bias.factor,2,remove.leading0=F), "&", formatDouble(res[2,a]*bias.factor,2,remove.leading0=F), "--", ifelse(res[3,a]*bias.factor>1000,"Inf",formatDouble(res[3,a]*bias.factor,2,remove.leading0=F))
        , "&" ,
        # E-value and ub
        formatDouble(E.value(res[1,a]),1), "&", formatDouble(E.value(res[3,a]),1)
    )
})
write(concatList(tab, "\\\\"), file=paste0(save.results.to, "marginalized_risks_cat.tex"))



###################################################################################################
# trichotomized markers, marginalized risk curves over time
# no bootstrap

risks.all.ter=list()
for (a in all.markers) {        
  assay=marker.name.to.assay(a)
  marker.name=a%.%"cat"    
    f1=update(form.0, as.formula(paste0("~.+",marker.name)))        
    fit.risk=run.svycoxph(f1, design=twophase(id=list(~1,~1), strata=list(NULL,~Wstratum), subset=~ph2, data=dat.ph1))
    
#    f2=update(form.0, as.formula(paste0(marker.name,"~.")))
#    fit.s=nnet::multinom(f2, dat.ph1, weights=dat.ph1$wt) 
        
    if(length(fit.risk)==1) {
        risks.all.ter[[a]]=NA
    } else {
        risks.all.ter[[a]]=marginalized.risk(fit.risk, marker.name, subset(dat.ph1,ph2==1), weights=subset(dat.ph1,ph2==1,wt,drop=T), categorical.s=T, t.end=tfinal.tpeak)
    }
}
#rv$marginalized.risk.over.time=list()
#for (a in assays) rv$marginalized.risk.over.time[[a]] = risks.all.ter[[a]]


# # get cumulative risk from placebo
# fit.0=coxph(form.s, dat.pla.seroneg) 
# risk.0= 1 - exp(-predict(fit.0, type="expected"))
# time.0= dat.pla.seroneg$EventTimePrimary
# # risk.0 for 7 and 7+ are different
# keep=dat.pla.seroneg$EventIndPrimary==1 & time.0<=tfinal.tpeak
# risk.0 = risk.0[keep]
# time.0 = time.0[keep]

#fit.1=coxph(form.s, dat.ph1) 
#risk.1= 1 - exp(-predict(fit.1, type="expected"))
#time.1= dat.ph1EventTimePrimary
#mypdf(file="tmp")
#    plot(time.1, risk.1)
#    mylines(time.0, risk.0, col="gray", lwd=2)
#    mylegend(x=1, legend=c("placebo","vaccine"), col=c("gray","black"), lty=1)
#dev.off()

lwd=2
ylim=c(0,
       max(sapply(all.markers, function(a) max(risks.all.ter[[a]]$risk[risks.all.ter[[a]]$time<=tfinal.tpeak,])))
       # max(risk.0, sapply(all.markers, function(a) max(risks.all.ter[[a]]$risk[risks.all.ter[[a]]$time<=tfinal.tpeak,])))
)

x.time<-seq(0,tfinal.tpeak,by=30)
if(.mfrow[1]==1)  height=7.5/2*1.5 else height=7.5/2*.mfrow[1]*1.3

for (a in all.markers) {        
  assay=marker.name.to.assay(a)
  mypdf(oma=c(1,0,0,0), onefile=F, file=paste0(save.results.to, a, "_marginalized_risks_cat"), mfrow=.mfrow, mar=c(12,4,5,2))
    par(las=1, cex.axis=0.9, cex.lab=1)# axis label 
    
    marker.name=a%.%"cat"    
    
    out=risks.all.ter[[a]]
    # cutpoints
    q.a=marker.cutpoints[[a]]
    
    if(length(out)==1) empty.plot() else {
        mymatplot(out$time[out$time<=tfinal.tpeak], out$risk[out$time<=tfinal.tpeak,], lty=1:3, col=c("green3","green","darkgreen"), type="l", lwd=lwd, make.legend=F, ylab=paste0("Probability* of ",config$txt.endpoint), ylim=ylim, xlab="", las=1, 
            xlim=c(0,tfinal.tpeak), at=x.time, xaxt="n")
        title(xlab="Days Since "%.%config$peak_visit%.%" Visit", line=2)
        title(main=assay_labels[assay], cex.main=.9, line=2)
        mtext(bquote(cutpoints: list(.(formatDouble(10^q.a[1]/10^floor(q.a[1]),1)) %*% 10^ .(floor(q.a[1])), .(formatDouble(10^q.a[2]/10^floor(q.a[2]),1)) %*% 10^ .(floor(q.a[2])))), line= .25, cex=.8)   
        legend=c("Vaccine low","Vaccine medium","Vaccine high")
        mylegend(x=1, legend=legend, lty=c(1:3), col=c("green3","green","darkgreen"), lwd=2)
        # mylines(time.0, risk.0, col="gray", lwd=2, type="l")
    }
    
    # save source data for images per some journals' requirements
    img.dat=cbind(out$time[out$time<=tfinal.tpeak], out$risk[out$time<=tfinal.tpeak,])
    rownames(img.dat)=img.dat[,1]
    # # add placebo risk
    # tmp=cbind(time.0, risk.0)
    # tmp=tmp[order (tmp[,1]),]
    # tmp=unique(tmp)    
    # rownames(tmp)=tmp[,1]
    # # combine and sort
    # img.dat=cbinduneven(list(img.dat, tmp))
    # img.dat=img.dat[order(img.dat[,5]),]
    mywrite.csv(img.dat, paste0(save.results.to, a, "_marginalized_risks_cat"))
    
    
    # add data ribbon
    f1=update(form.s, as.formula(paste0("~.+",marker.name)))
    km <- survfit(f1, subset(dat.ph1, ph2==1), weights=wt)
    tmp=summary(km, times=x.time)            
    
#    stopifnot(all(tmp$time[1:length(x.time)]==x.time))
#    stopifnot(tmp$time[1:length(x.time)+length(x.time)]==x.time)
#    stopifnot(tmp$time[1:length(x.time)+length(x.time)*2]==x.time)
    
    L.idx=which(tmp$time==0)[1]:(which(tmp$time==0)[2]-1)
    M.idx=which(tmp$time==0)[2]:(which(tmp$time==0)[3]-1)
    H.idx=which(tmp$time==0)[3]:length(tmp$time==0)
    
    n.risk.L <- round(tmp$n.risk[L.idx])
    n.risk.M <- round(tmp$n.risk[M.idx])
    n.risk.H <- round(tmp$n.risk[H.idx])
    
    cum.L <- round(cumsum(tmp$n.event[L.idx]))
    cum.M <- round(cumsum(tmp$n.event[M.idx]))
    cum.H <- round(cumsum(tmp$n.event[H.idx]))
    
    # add placebo
    # tmp.P=summary(survfit(form.s, dat.pla.seroneg), times=x.time)            
    # n.risk.P <- round(tmp.P$n.risk)
    # cum.P <- round(cumsum(tmp.P$n.event))    
    
    cex.text <- 0.7
    at.label=-tfinal.tpeak/6
    
    mtext("No. at risk",side=1,outer=FALSE,line=2.5,at=-2,adj=0,cex=cex.text)
    mtext(paste0("Low:"),side=1,outer=F,line=3.4,at=at.label,adj=0,cex=cex.text);  mtext(n.risk.L,side=1,outer=FALSE,line=3.4,at=tmp$time[L.idx],cex=cex.text)
    mtext(paste0("Med:"),side=1,outer=F,line=4.3,at=at.label,adj=0,cex=cex.text);  mtext(n.risk.M,side=1,outer=FALSE,line=4.3,at=tmp$time[M.idx],cex=cex.text)
    mtext(paste0("High:"),side=1,outer=F,line=5.2,at=at.label,adj=0,cex=cex.text); mtext(n.risk.H,side=1,outer=FALSE,line=5.2,at=tmp$time[H.idx],cex=cex.text)
    # mtext(paste0("Plac:"),side=1,outer=F,line=6.2,at=at.label,adj=0,cex=cex.text); mtext(n.risk.P,side=1,outer=FALSE,line=6.2,at=tmp.P$time,cex=cex.text)
    
    mtext(paste0("Cumulative No. of ",config$txt.endpoint," Endpoints"),side=1,outer=FALSE,line=7.4,at=-2,adj=0,cex=cex.text)
    mtext(paste0("Low:"),side=1,outer=FALSE,line=8.3,at=at.label,adj=0,cex=cex.text);  mtext(cum.L,side=1,outer=FALSE,line=8.3,at=tmp$time[L.idx],cex=cex.text)
    mtext(paste0("Med:"),side=1,outer=FALSE,line=9.2,at=at.label,adj=0,cex=cex.text);  mtext(cum.M,side=1,outer=FALSE,line=9.2,at=tmp$time[M.idx],cex=cex.text)
    mtext(paste0("High:"),side=1,outer=FALSE,line=10.1,at=at.label,adj=0,cex=cex.text);mtext(cum.H,side=1,outer=FALSE,line=10.1,at=tmp$time[H.idx],cex=cex.text)
    # mtext(paste0("Plac:"),side=1,outer=FALSE,line=11.1,at=at.label,adj=0,cex=cex.text);mtext(cum.P,side=1,outer=FALSE,line=11.1,at=tmp.P$time,cex=cex.text)
    
dev.off()    
}
#mtext(toTitleCase(study_name), side = 1, line = 2, outer = T, at = NA, adj = NA, padj = NA, cex = .8, col = NA, font = NA)
#
#cumsum(summary(survfit(form.s, subset(dat.ph1, ph2==1)), times=x.time)$n.event)
#table(subset(dat.ph1, yy==1)[["Day"%.%tpeak%.%"pseudoneutid80cat"]])



###################################################################################################
# for goodness of fit check on PH assumptions, plot log(-log) marginalized survival curves for the low medium and high tertile subgroups

for (a in all.markers) {        
  assay=marker.name.to.assay(a)
  mypdf(onefile=F, file=paste0(save.results.to, a, "_marginalized_risks_cat_logclog"), mfrow=.mfrow)
    marker.name=a%.%"cat"    
    
    out=risks.all.ter[[a]]
    # cutpoints
    q.a=marker.cutpoints[[a]]
    
    if(length(out)==1) empty.plot() else {
        mymatplot(out$time[out$time<=tfinal.tpeak], log(-log(out$risk[out$time<=tfinal.tpeak,])), 
            lty=1:3, col=c("green3","green","darkgreen"), type="l", lwd=lwd, make.legend=F, 
            ylab=paste0("log(-log(Probability* of ",config$txt.endpoint," by Day "%.%tfinal.tpeak, "))"), xlab="", 
            las=1, xlim=c(0,tfinal.tpeak), at=x.time, xaxt="n")
        title(xlab="Days Since "%.%config$peak_visit%.%" Visit", line=2)
        title(main=assay_labels[assay], cex.main=.9, line=2)
        mtext(bquote(cutpoints: list(.(formatDouble(10^q.a[1]/10^floor(q.a[1]),1)) %*% 10^ .(floor(q.a[1])), .(formatDouble(10^q.a[2]/10^floor(q.a[2]),1)) %*% 10^ .(floor(q.a[2])))), line= .25, cex=.8)   
        legend=c("Vaccine low","Vaccine medium","Vaccine high")
        mylegend(x=3, legend=legend, lty=c(1:3), col=c("green3","green","darkgreen"), lwd=2)
    }
    
dev.off()    
}


