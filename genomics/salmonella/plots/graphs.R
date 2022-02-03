pangenome <- read.csv("curated_pangenomeMatrix.csv")

length(which(pangenome$Groups == "typhimurium"))

length(which(pangenome$Groups == "newport_g2"))

length(which(pangenome$Groups == "newport_g3"))

df <- read.csv("Competitions.csv")

df_unique <- df[(grep("peg", df$Gene)),]

df_AA <- df[(grep("peg", df$Gene, invert = T)),]

library(ggplot2)
library(bear)

df_unique_s<- summarySE(df_unique, measurevar="log2.CI.", groupvars="Gene")
df_AA_s<- summarySE(df_AA, measurevar="log2.CI.", groupvars="Gene")

###

df_AA$Gene<-factor(df_AA$Gene, levels=df_AA_s$Gene[order(df_AA_s$log2.CI., decreasing=TRUE)])

ggplot()+
  geom_jitter(aes(Gene, log2.CI.), data = df_AA, colour = I("black"),pch=1, size=6 ,
              position = position_jitter(width = 0.3)) +
  geom_crossbar(data=df_AA_s,aes(x=Gene,ymin=log2.CI., ymax=log2.CI., y=log2.CI. ), width = 0.6)+ 
  scale_y_continuous(limits=c(-7.5, 2.5), breaks =c(-7.5,-5,-2.5,0,2.5)) +
  theme_bw()

###

df_unique$Gene<-factor(df_unique$Gene, levels=df_unique_s$Gene[order(df_unique_s$log2.CI., decreasing=TRUE)])

ggplot()+
  geom_jitter(aes(Gene, log2.CI.), data = df_unique, colour = I("black"),pch=1, size=6 ,
              position = position_jitter(width = 0.3)) +
  geom_crossbar(data=df_unique_s,aes(x=Gene,ymin=log2.CI., ymax=log2.CI., y=log2.CI. ), width = 0.6)+ 
  scale_y_continuous(limits=c(-7.5, 5), breaks =c(-7.5,-5,-2.5,0,2.5,5)) +
  theme_bw()


