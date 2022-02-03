#!/usr/bin/env Rscript

library(ggplot2)
library(RColorBrewer)
library(ade4)
library(pvclust)
library(ape)
library(reshape2)
library(grid)

pan_file<-'Pan1526.csv'
pangenome<-read.csv(pan_file)
dim(pangenome)
pangenome[1:30,1:8]

# Definitions
numOfColMeta<-7
coreCutOff<-0.95

numOfGenomes<-nrow(pangenome)
CoreBorder<-coreCutOff*numOfGenomes


#### Calculating the Distance Matrix ####

panNumeric<-pangenome[,-(1:numOfColMeta)]
GeneCount<-colSums(panNumeric)

# Removing Singletons and Core Genome
GenesToKeep<-GeneCount[GeneCount!=1 & GeneCount<CoreBorder]
panNumeric2<-panNumeric[names(GenesToKeep)]
# Calculating binaty distance
# by Jaccard Index
bin_dist<-dist.binary(panNumeric2,method=1,diag=T)
bin_dist2<-as.matrix(bin_dist)

######## PCoA using cmdscale function ##########
# K equal to number of dimensions to return
k <- 3
pcoa <- cmdscale(bin_dist2, k=k, eig=T)

points <- pcoa$points
eig <- pcoa$eig
points <- as.data.frame(points)
colnames(points) <- c("x", "y", "z")

dim(points)
points[1:5,1:3]

#Creadate dataframe to map from
points$serovar <- pangenome$Serovars[match(rownames(points), rownames(pangenome))]
points$groups <- pangenome$Groups[match(rownames(points), rownames(pangenome))]
points$sources <- pangenome$Sources[match(rownames(points), rownames(pangenome))]
points$places <- pangenome$Places[match(rownames(points), rownames(pangenome))]
points$dates <- pangenome$Dates[match(rownames(points), rownames(pangenome))]
points$size <- pangenome$Size[match(rownames(points), rownames(pangenome))]

# Colors to use 16 different taxonomic colors
colores<-c(brewer.pal(12,"Set3"),brewer.pal(4,"Dark2"))
colores_type<-c("mediumpurple4","mediumseagreen","gray")

# Ploting using ggplot2 components 1 and 2 coloring by taxonomy
# You can plot component 1 versus 3 by modifying x=x,y=z or 2 versus 3 x=y,y=z
p1 <- ggplot(data=points, aes(x=x, y=y, color=serovar)) +
  geom_point(alpha=.8) +
  scale_colour_manual(values=colores) +
  labs(x=paste("PCoA 1 (", format(100 * eig[1] / sum(eig), digits=4), "%)", sep=""),
       y=paste("PCoA 2 (", format(100 * eig[2] / sum(eig), digits=4), "%)", sep="")) + 
  theme(legend.title=element_blank())
p1
ggsave(filename="PcoASerovars.png",p1,width=20,height=20,units="cm")

p2 <- ggplot(data=points, aes(x=x, y=y, color=groups)) +
  geom_point(alpha=.8) +
  scale_colour_manual(values=colores) +
  labs(x=paste("PCoA 1 (", format(100 * eig[1] / sum(eig), digits=4), "%)", sep=""),
       y=paste("PCoA 2 (", format(100 * eig[2] / sum(eig), digits=4), "%)", sep="")) + 
  theme(legend.title=element_blank())
p2
ggsave(filename="PcoAGroups.png",p2,width=20,height=20,units="cm")

p3 <- ggplot(data=points, aes(x=x, y=y, color=sources)) +
  geom_point(alpha=.8) +
  scale_colour_manual(values=colores) +
  labs(x=paste("PCoA 1 (", format(100 * eig[1] / sum(eig), digits=4), "%)", sep=""),
       y=paste("PCoA 2 (", format(100 * eig[2] / sum(eig), digits=4), "%)", sep="")) + 
  theme(legend.title=element_blank())
p3
ggsave(filename="PcoASources.png",p3,width=20,height=20,units="cm")

p4 <- ggplot(data=points, aes(x=x, y=y, color=places)) +
  geom_point(alpha=.8) +
  scale_colour_manual(values=colores) +
  labs(x=paste("PCoA 1 (", format(100 * eig[1] / sum(eig), digits=4), "%)", sep=""),
       y=paste("PCoA 2 (", format(100 * eig[2] / sum(eig), digits=4), "%)", sep="")) + 
  theme(legend.title=element_blank())
p4
ggsave(filename="PcoAPlaces.png",p4,width=20,height=20,units="cm")

levels(points$dates)<-c('Other','Other','Other','Other','Other','Other','Other','Other','Other',
                        'Other','Other','Other','Other','Other','2007','Other','Other','Other',
                        'Other','2012','Other','2014','2015','Other')
points2<-subset(points,dates!='Other')

p5 <- ggplot(data=points2, aes(x=x, y=y, color=dates)) +
  geom_point(alpha=.8) +
  scale_colour_manual(values=colores) +
  labs(x=paste("PCoA 1 (", format(100 * eig[1] / sum(eig), digits=4), "%)", sep=""),
       y=paste("PCoA 2 (", format(100 * eig[2] / sum(eig), digits=4), "%)", sep="")) + 
  theme(legend.title=element_blank())
p5
ggsave(filename="PcoADates.png",p5,width=20,height=20,units="cm")

Q25<-quantile(points$size,seq(0,1,0.25))
points$sizeCat<-cut(points$size,Q25)
levels(points$sizeCat)<-c('4216-4540','4541-4596','4597-4652','4653-4947')

p7 <- ggplot(data=points, aes(x=x, y=y, color=sizeCat)) +
  geom_point(alpha=.8) +
  scale_colour_manual(values=colores) +
  labs(x=paste("PCoA 1 (", format(100 * eig[1] / sum(eig), digits=4), "%)", sep=""),
       y=paste("PCoA 2 (", format(100 * eig[2] / sum(eig), digits=4), "%)", sep="")) + 
  theme(legend.title=element_blank())
p7
ggsave(filename="PcoASize.png",p7,width=20,height=20,units="cm")

p8 <- ggplot(data=points, aes(x=x, y=z, color=groups)) +
  geom_point(alpha=.8) +
  scale_colour_manual(values=colores) +
  labs(x=paste("PCoA 1 (", format(100 * eig[1] / sum(eig), digits=4), "%)", sep=""),
       y=paste("PCoA 3 (", format(100 * eig[3] / sum(eig), digits=4), "%)", sep="")) + 
  theme(legend.title=element_blank())
p8
ggsave(filename="PcoAGroupsXZ.png",p8,width=20,height=20,units="cm")


p2 <- ggplot(data=points, aes(x=x, y=y, color=groups)) +
  geom_point(alpha=.8) +
  scale_colour_manual(values=c("#CC0000", "#009900", "#6666FF")) +
  labs(x=paste("PCoA 1 (", format(100 * eig[1] / sum(eig), digits=4), "%)", sep=""),
       y=paste("PCoA 2 (", format(100 * eig[2] / sum(eig), digits=4), "%)", sep="")) + 
  theme_light()
p2
ggsave(filename="PcoAGroups2.png",p2,width=20,height=20,units="cm")
