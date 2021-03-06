#!/usr/bin/env R

#!R
Args <- commandArgs()
NullModel=Args[6]
outputname=Args[7]
boxcolor=Args[8]
linecolor=Args[9]
outputname2=Args[10]
Window_Size=Args[11]

outputFileType=strsplit(outputname,'[.]')[[1]][length(strsplit(outputname,'[.]')[[1]])]
dataNull=read.table(file=NullModel,header=F)
dataNull=dataNull[order(dataNull[,1],decreasing=F),]
if(sum(dataNull[,2])>2^18-1){
    shrink=as.integer(sum(dataNull[,2])/2^18-1)+3
    dataNull[,2]=dataNull[,2]/shrink
    }
#MedianData=median(dataNull[,1])
#for(i in nrow(dataNull):1){
#    if(dataNull[i,1]>3*MedianData){
#        dataNull=dataNull[-i,]
#    }
#    }
StatType=strsplit(strsplit(NullModel,'/')[[1]][length(strsplit(NullModel,'/')[[1]])],'[.]')[[1]][1]

if (StatType=='RDNull'){
    data_RD=c()
    for(i in 1:nrow(dataNull)){    data_RD=c(data_RD,rep(dataNull[i,1],dataNull[i,2]))}
    RD_Mean=mean(data_RD)
    RD_Median=median(data_RD)
    RD_STD=sd(data_RD)
    total_length=length(data_RD)
    data_RD=data_RD[as.integer(total_length/40):as.integer(total_length-total_length/40)]
    p=RD_Mean/RD_STD^2
    r=RD_Mean*p/(1-p)
    xrange=range(min(data_RD),max(data_RD))
    yrange=range(0,max(dataNull[,2]/sum(dataNull[,2])))
    if(outputFileType=='pdf'){    pdf(outputname)}
    if(outputFileType=='jpg'){    jpeg(outputname)}
    if(outputFileType=='png'){    png(outputname)}
    par(mfrow=c(1,2))
    par(mar=rep(3,4))
    par(fig=c(0.1,0.6,0,1))
    cex_main=0.9
    break_num=as.integer(nrow(dataNull)/2)
    if (nrow(dataNull)>500){        break_num=as.integer(nrow(dataNull)/5)}
    #plot(xrange,yrange,xlab='Read Depth',ylab='Frequency',cex.main=0.8,main='Fitted by NB',type='n',xaxt='n',yaxt='n',frame.plot=F)
    data_RD3=data_RD[data_RD<3*RD_Mean]
    hist(data_RD3,xaxt='n',xlab='Read Depth',ylab='',freq=F,cex.main=cex_main,main='Fitted by NB',col=boxcolor,breaks=break_num)
    lines(seq(range(data_RD3)[1],range(data_RD3)[2],1),dnbinom(seq(range(data_RD3)[1],range(data_RD3)[2],1),r,p),type='l',lwd=2,col=linecolor)
    axis(1,c(xrange[1],xrange[1]+(xrange[2]-xrange[1])/4,xrange[1]+(xrange[2]-xrange[1])/2,xrange[1]+3*(xrange[2]-xrange[1])/4,xrange[2]),round(c(xrange[1],xrange[1]+(xrange[2]-xrange[1])/4,xrange[1]+(xrange[2]-xrange[1])/2,xrange[1]+3*(xrange[2]-xrange[1])/4,xrange[2])/as.double(Window_Size),digits=2))

    par(fig=c(0,0.15,0,1),new=T)
    par(mar=rep(1,4))
    plot(c(0,1),c(0,1),type='n',xlab='',ylab='',axes=FALSE)
    text(0.5,0.5,'Frequency',srt=90)

    par(fig=c(0.5,1,0,1),new=T)
    par(mar=rep(3,4))
    hist( data_RD3,xaxt='n',freq=F,col=boxcolor,breaks=break_num,xlab='Read Depth',ylab='',cex.main=0.8,main='Fitted by Normal')
    lines(seq(range(data_RD3)[1],range(data_RD3)[2],1),dnorm(seq(range(data_RD3)[1],range(data_RD3)[2],1),RD_Mean,RD_STD),type='l',lwd=2,col=linecolor)
    axis(1,c(xrange[1],xrange[1]+(xrange[2]-xrange[1])/4,xrange[1]+(xrange[2]-xrange[1])/2,xrange[1]+3*(xrange[2]-xrange[1])/4,xrange[2]),round(c(xrange[1],xrange[1]+(xrange[2]-xrange[1])/4,xrange[1]+(xrange[2]-xrange[1])/2,xrange[1]+3*(xrange[2]-xrange[1])/4,xrange[2])/as.double(Window_Size),digits=2))
    #axis(2,c(yrange[1],yrange[1]+(yrange[2]-yrange[1])/3,yrange[1]+2*(yrange[2]-yrange[1])/3,yrange[2]),round(c(yrange[1],yrange[1]+(yrange[2]-yrange[1])/3,yrange[1]+2*(yrange[2]-yrange[1])/3,yrange[2]),digits=2))
    dev.off()
    StatMatrix=data.frame(Mean=RD_Mean,Median=RD_Median,STD=RD_STD)
    write.table(file=outputname2,StatMatrix,quote=F,row.name=F)
    }

if (StatType=='ILNull'){
    library(mixtools)
    data_IL=c()
    for(i in 1:nrow(dataNull)){
    data_IL=c(data_IL,rep(dataNull[i,1],dataNull[i,2]))
    }
    total_length=length(data_IL)
    data_IL2=data_IL[as.integer(total_length/40): as.integer(total_length-total_length/40)]
    IL_Mean=mean(data_IL2)
    IL_Median=median(data_IL2)
    IL_STD=sd(data_IL2)
    mixmdl = normalmixEM(data_IL2)
    IL_Normal_Mean=IL_Mean
    IL_Normal_STD=IL_STD
    if(outputFileType=='pdf'){    pdf(outputname)}
    if(outputFileType=='jpg'){    jpeg(outputname)}
    if(outputFileType=='png'){    png(outputname)}
    xin=c(1:dataNull[nrow(dataNull),1])
    yin=mixmdl$lambda[1] * dnorm(xin,mean=mixmdl$mu[1],sd=mixmdl$sigma[1])+mixmdl$lambda[2] * dnorm(xin,mean=mixmdl$mu[2],sd=mixmdl$sigma[2])
    xrange=range(min(data_IL)*0.9,min(max(data_IL)*1.1,IL_Mean*3))
    yrange=range(0,max(yin)*1.2)
    par(mfrow=c(1,2))
    par(mar=rep(3,4))
    par(fig=c(0.1,0.6,0,1))
    cex_main=0.9
    break_num=as.integer(nrow(dataNull)/2)
    if (nrow(dataNull)>500){        break_num=as.integer(nrow(dataNull)/5)}
    plot(xrange,yrange,type='n',frame.plot=F,xlab='Insert Length',cex.main=cex_main,main='Fitted By Bimodal')
    hist(data_IL2,freq=F,col=boxcolor,breaks=break_num,add=T)
    lines(xin,yin,pch='l',col=linecolor)
    
    par(fig=c(0,0.15,0,1),new=T)
    par(mar=rep(1,4))
    plot(c(0,1),c(0,1),type='n',xlab='',ylab='',axes=FALSE)
    text(0.5,0.5,'Frequency',srt=90)

    par(fig=c(0.5,1,0,1),new=T)
    par(mar=rep(3,4))
    plot(xrange,yrange,type='n',frame.plot=F,xlab='Insert Length',cex.main=cex_main,main='Fitted By Normal')
    hist(data_IL2,freq=F,col=boxcolor,breaks=break_num,xlim=xrange,add=T)
    lines(seq(range(data_IL)[1],range(data_IL)[2],1),dnorm(seq(range(data_IL)[1],range(data_IL)[2],1),IL_Normal_Mean,IL_Normal_STD),type='l',lwd=2,col=linecolor)
    dev.off()

    StatMatrix1=data.frame(Mean=IL_Mean, Median=IL_Median, STD=IL_STD)
    StatMatrix2=data.frame(Bimodal1=mixmdl$lambda[1],Mean1=mixmdl$mu[1], STD1=mixmdl$sigma[1])
    StatMatrix3=data.frame(Bimodal2=mixmdl$lambda[2],Mean2=mixmdl$mu[2], STD2=mixmdl$sigma[2])
    StatMatrix4=data.frame(Normal=1, Mean=IL_Normal_Mean, STD=IL_Normal_STD)
    StatMatrix=rbind(colnames(StatMatrix1),c(StatMatrix1[1,]),
    colnames(StatMatrix2),c(StatMatrix2[1,]),
    colnames(StatMatrix3),c(StatMatrix3[1,]),
    colnames(StatMatrix4),c(StatMatrix4[1,]))
    write.table(file=outputname2,StatMatrix,quote=F,col.name=F,row.name=F)
    }

if (StatType=='TBNull'){
    library(mixtools)
    data_TB=c()
    for(i in 1:nrow(dataNull)){
    data_TB=c(data_TB,rep(dataNull[i,1],dataNull[i,2]))
    }
    total_length=length(data_TB)
    data_TB2=data_TB[as.integer(total_length/40): as.integer(total_length-total_length/40)]
    TB_Mean=mean(data_TB2)
    TB_Median=median(data_TB2)
    TB_STD=sd(data_TB2)
    mixmdl = normalmixEM(data_TB2)
    TB_Normal_Mean=TB_Mean
    TB_Normal_STD=TB_STD
    if(outputFileType=='pdf'){    pdf(outputname)}
    if(outputFileType=='jpg'){    jpeg(outputname)}
    if(outputFileType=='png'){    png(outputname)}
    xin=c(1:dataNull[nrow(dataNull),1])
    yin=mixmdl$lambda[1] * dnorm(xin,mean=mixmdl$mu[1],sd=mixmdl$sigma[1])+mixmdl$lambda[2] * dnorm(xin,mean=mixmdl$mu[2],sd=mixmdl$sigma[2])
    xrange=range(min(data_TB)*0.9,min(max(data_TB)*1.1,TB_Mean*3))
    yrange=range(0,max(yin)*1.2)
    par(mfrow=c(1,2))
    par(mar=rep(3,4))
    par(fig=c(0.1,0.6,0,1))
    cex_main=0.9
    break_num=as.integer(nrow(dataNull)/2)
    if (nrow(dataNull)>500){        break_num=as.integer(nrow(dataNull)/5)}
    plot(xrange,yrange,type='n',frame.plot=F,xlab='Insert Length',cex.main=cex_main,main='Fitted By Bimodal')
    hist(data_TB2,freq=F,col=boxcolor,breaks=break_num,add=T)
    lines(xin,yin,pch='l',col=linecolor)
    
    par(fig=c(0,0.15,0,1),new=T)
    par(mar=rep(1,4))
    plot(c(0,1),c(0,1),type='n',xlab='',ylab='',axes=FALSE)
    text(0.5,0.5,'Frequency',srt=90)

    par(fig=c(0.5,1,0,1),new=T)
    par(mar=rep(3,4))
    plot(xrange,yrange,type='n',frame.plot=F,xlab='Insert Length',cex.main=cex_main,main='Fitted By Normal')
    hist(data_TB2,freq=F,col=boxcolor,breaks=break_num,xlim=xrange,add=T)
    lines(seq(range(data_TB)[1],range(data_TB)[2],1),dnorm(seq(range(data_TB)[1],range(data_TB)[2],1),TB_Normal_Mean,TB_Normal_STD),type='l',lwd=2,col=linecolor)
    dev.off()

    StatMatrix1=data.frame(Mean=TB_Mean, Median=TB_Median, STD=TB_STD)
    StatMatrix2=data.frame(Bimodal1=mixmdl$lambda[1],Mean1=mixmdl$mu[1], STD1=mixmdl$sigma[1])
    StatMatrix3=data.frame(Bimodal2=mixmdl$lambda[2],Mean2=mixmdl$mu[2], STD2=mixmdl$sigma[2])
    StatMatrix4=data.frame(Normal=1, Mean=TB_Normal_Mean, STD=TB_Normal_STD)
    StatMatrix=rbind(colnames(StatMatrix1),c(StatMatrix1[1,]),
    colnames(StatMatrix2),c(StatMatrix2[1,]),
    colnames(StatMatrix3),c(StatMatrix3[1,]),
    colnames(StatMatrix4),c(StatMatrix4[1,]))
    write.table(file=outputname2,StatMatrix,quote=F,col.name=F,row.name=F)
    }
