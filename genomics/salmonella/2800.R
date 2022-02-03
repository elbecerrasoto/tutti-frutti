#!/usr/bin/env Rscript

setwd("/media/ebecerra/2ce97da3-6206-4ea6-a2bd-edaaa8606ac3/home/ebecerra/2UF/0209Pan")

########################## Procccesing the Raw Roary table ############################################

# file<-'gene_presence_absence.Rtab'
# 
# pan2800<-read.table(file,header=T)
# rownames(pan2800)<-pan2800$Gene
# 
# pan2800.2<-pan2800[,2:ncol(pan2800)]
# Size<-colSums(pan2800.2)
# 
# pan2800.3<-t(pan2800.2)
# pan2800.3<-as.data.frame(pan2800.3)
# 
# pan2800.3$Size<-Size
# pan2800.3$SName<-names(Size)
# 
# pan2800.4<-pan2800.3[,c(ncol(pan2800.3),ncol(pan2800.3)-1,1:(ncol(pan2800.3)-2))]
# pan2800.5<-pan2800.4[,2:ncol(pan2800.4)]
# 
# write.csv(x=pan2800.5,file='2800_PanMatrix.csv')

####################### Mapping the Serovars ######################################################

# file<-'/media/ebecerra/2ce97da3-6206-4ea6-a2bd-edaaa8606ac3/home/ebecerra/UF/New_Typm_Pan_Project/Pan1526.csv'
# Pan1526<-read.csv(file)
# 
# Pan1526[1:10,1:10]
# SerGrp1526<-Pan1526[,c(3,4)]
# write.csv(SerGrp1526,'NewTypmList.csv')

file<-'2800_PanMatrix.csv'
file2<-'Serotyped.csv'

pan2800<-read.csv(file)
SeroMeta<-read.csv(file2,header=F)

pan2800.2<-cbind(  SeroMeta  [ match(SeroMeta$V1,rownames(pan2800)) ,  ] , pan2800  )
pan2800.2[1:10,1:10]
names(pan2800.2)[1]<-'Genomes'
names(pan2800.2)[2]<-'Serovars'

write.csv(pan2800.2,'2_2800_PanMatrix.csv')
summary(pan2800.2$Size)


library(ggplot2)
ggplot(data=pan2800.2,aes(x=Size,fill=Serovars)) + 
  geom_histogram(breaks=seq(4000, 5000, by=50)) + 
  labs(title="Gene Count Per Genome") +
  labs(x="Number Of Genes", y="Number of Genomes")



levels(pan2800.2$Serovars)
Agona<-subset(pan2800.2,pan2800.2$Serovars=='Agona')
Braenderup<-subset(pan2800.2,pan2800.2$Serovars=='Braenderup')
Javiana<-subset(pan2800.2,pan2800.2$Serovars=='Javiana')
Montevideo<-subset(pan2800.2,pan2800.2$Serovars=='Montevideo')
Newport<-subset(pan2800.2,pan2800.2$Serovars=='Newport')
Poona<-subset(pan2800.2,pan2800.2$Serovars=='Poona')
Saintpaul<-subset(pan2800.2,pan2800.2$Serovars=='Saintpaul')
Typhimurium<-subset(pan2800.2,pan2800.2$Serovars=='Typhimurium')


ggplot()+
  geom_boxplot(data=Agona, aes(x='Agna',y=Size),lwd=1)+
  geom_boxplot(data=Braenderup, aes(x='Braen',y=Size),lwd=1)+
  geom_boxplot(data=Javiana, aes(x='Javi',y=Size),lwd=1)+
  geom_boxplot(data=Montevideo, aes(x='Mont',y=Size),lwd=1)+
  geom_boxplot(data=Newport, aes(x='Newp',y=Size),lwd=1)+
  geom_boxplot(data=Poona, aes(x='Poona',y=Size),lwd=1)+
  geom_boxplot(data=Saintpaul, aes(x='Spal',y=Size),lwd=1)+
  geom_boxplot(data=Typhimurium, aes(x='Typm',y=Size),lwd=1)+
  ylab('Protein Coding Genes')+ggtitle('Genome Size')+
  theme(
    # Plot title
    plot.title = element_text(size = 20),
    # Outside X,Y text
    axis.title.x = element_text(size = 0),
    axis.title.y = element_text(size = 18),
    # Inside X,Y text
    axis.text.x = element_text(size = 18),
    axis.text.y = element_text(size = 18),
    # Configure lines and axes
    axis.ticks.x = element_line(colour = "black"), 
    axis.ticks.y = element_line(colour = "black"), 
    # Plot background
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(colour = "grey70",size = 0.8), 
    panel.grid.minor = element_line(colour = "grey70",size = 0.8)
  )


######################### Building the PCoA #############################

setwd("/media/ebecerra/2ce97da3-6206-4ea6-a2bd-edaaa8606ac3/home/ebecerra/2UF/0209Pan")
# Loading the files
file<-'3_2800PanMatrix.csv'
PanMatrix<-read.csv(file)

library(ggplot2)
library(RColorBrewer)
library(ade4)
library(pvclust)
library(ape)
library(reshape2)
library(grid)


PanMatrix[1:10,1:10]
panNumeric<-PanMatrix[,3:ncol(PanMatrix)]
panNumeric[1:10,1:10]

# Check Free Memory
#memfree<-as.numeric(system("awk '/MemFree/ {print $2}' /proc/meminfo",intern=TRUE))
#memfree

# gc to free RAM memory
#gc(PanMatrix)


# Calculating binary distance
# 10 minutes for 50,000 columns and about 6 GB
# by Jaccard Index
bin_dist<-dist.binary(panNumeric,method=1,diag=T)
bin_dist2<-as.matrix(bin_dist)


# PCoA using cmdscale function
# K equal to number of dimensions to return
k <- 3
pcoa <- cmdscale(bin_dist2, k=k, eig=T)







points <- pcoa$points
eig <- pcoa$eig
points <- as.data.frame(points)
colnames(points) <- c("x", "y", "z")

dim(points)
points[1:5,1:3]

m<-match(    rownames(points) , rownames(PanMatrix) )
plot(m)

points$Serovar <- PanMatrix$Serovar[       match(    rownames(points) , rownames(PanMatrix)  )   ]
points$Size <- PanMatrix$Size[match(rownames(points), rownames(PanMatrix))]


# Colors to use 16 different taxonomic colors
colores<-c(brewer.pal(12,"Set3"),brewer.pal(4,"Dark2"))

#Another vector of colors
#colores_type<-c("mediumpurple4","mediumseagreen","gray")

# New palette high contrasting Colors
colores <- brewer.pal("Accent")

#Custom Pallete
colores<-c("#727272","#f1595f","#79c36a","#599ad3","#f9a65a","#9e66ab","#cd7058","#d77fb3")

# Ploting using ggplot2 components 1 and 2 coloring by taxonomy
# You can plot component 1 versus 3 by modifying x=x,y=z or 2 versus 3 x=y,y=z
p1<-ggplot(data=points, aes(x=x, y=y, color=Serovar)) +
  geom_point(alpha=.8) +
  scale_colour_manual(values=colores) +
  labs(x=paste("Coordinate 1     ", format(100 * eig[1] / sum(eig), digits=4), "%", sep=""),
       y=paste("Coordinate 2     ", format(100 * eig[2] / sum(eig), digits=4), "%", sep="")) +
  ggtitle('Salmonella Pangenome PCoA')

p1


p1.v2<-p1+theme(
    # Plot title
    plot.title = element_text(size = 20),
    # Outside X,Y text
    axis.title.x = element_text(size = 18),
    axis.title.y = element_text(size = 18),
    # Inside X,Y text
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12),
    # Configure lines and axes
    axis.ticks.x = element_line(colour = "black"), 
    axis.ticks.y = element_line(colour = "black"), 
    # Plot background
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(colour = "grey70",size = 0.8), 
    panel.grid.minor = element_line(colour = "grey70",size = 0.8),
    # Legend
    legend.title=element_blank(),
    legend.text=element_text(size=14),
    legend.position=c(0.9,0.2)
  )+guides(colour=guide_legend(override.aes = list(size=8)))

ggsave(filename="PcoASerovars.v2.png",p1.v2,width=20,height=20,units="cm")



#save.image(file='Bin_Dist_Complete.RData')
# Load R Data with the load function
#load(file='SomeFile.RData')


p2 <- ggplot(data=points, aes(x=x, y=z, color=Serovar)) +
  geom_point(alpha=.8) +
  scale_colour_manual(values=colores) +
  labs(x=paste("PCoA 1 (", format(100 * eig[1] / sum(eig), digits=4), "%)", sep=""),
       y=paste("PCoA 3 (", format(100 * eig[3] / sum(eig), digits=4), "%)", sep="")) + 
  theme(legend.title=element_blank())
p2
ggsave(filename="PcoASerovarsXZ.png",p2,width=20,height=20,units="cm")

############ Formating the Size into categories PCoA ##################

# Color using the genome Size (factor by quartiles)
Q25<-quantile(points$Size,seq(0,1,0.25))
# Create the levels
points$FacSize<-cut(points$Size,Q25)
# Rename the levels
levels(points$FacSize)<-c('4080-4362','4363-4530','4531-4622','4623-6122')

p3 <- ggplot(data=points, aes(x=x, y=y, color=FacSize)) +
  geom_point(alpha=.8) +
  scale_colour_manual(values=colores) +
  labs(x=paste("PCoA 1 (", format(100 * eig[1] / sum(eig), digits=4), "%)", sep=""),
       y=paste("PCoA 2 (", format(100 * eig[2] / sum(eig), digits=4), "%)", sep="")) + 
  theme(legend.title=element_blank())
p3
ggsave(filename="PcoASize.png",p3,width=20,height=20,units="cm")




########################### Cleaning the pangenome ################################

#!/usr/bin/env Rscript

setwd("~/ubuntu_ebecerra/2UF/0209Pan")
file<-'3_2800PanMatrix.csv'

PanMatrix<-read.csv(file)

toy<-PanMatrix[c(1:20,400:420,1560:1580,2600:2800),c(1:500,4000:4500)]
toy[1:10,1:10]
dim(toy)
ncol_toy_meta<-2

ntoy<-toy[       ,(ncol_toy_meta+1):ncol(toy)]
ntoy<-as.matrix(ntoy)
heatmap(ntoy)

PanMatrix[1:10,1:10]

table(PanMatrix$Serovar)

boxplot(PanMatrix$Size)

Agona<-subset(PanMatrix,PanMatrix$Serovar=='Agona')
Braenderup<-subset(PanMatrix,PanMatrix$Serovar=='Braenderup')
Javiana<-subset(PanMatrix,PanMatrix$Serovar=='Javiana')
Montevideo<-subset(PanMatrix,PanMatrix$Serovar=='Montevideo')
Newport<-subset(PanMatrix,PanMatrix$Serovar=='Newport')
Poona<-subset(PanMatrix,PanMatrix$Serovar=='Poona')
Saintpaul<-subset(PanMatrix,PanMatrix$Serovar=='Saintpaul')
Typhimurium<-subset(PanMatrix,PanMatrix$Serovar=='Typhimurium')

AgBx<-boxplot(as.vector(Agona$Size))
BrBx<-boxplot(as.vector(Braenderup$Size))
JaBx<-boxplot(as.vector(Javiana$Size))
MoBx<-boxplot(as.vector(Montevideo$Size))
NeBx<-boxplot(as.vector(Newport$Size))
PoBx<-boxplot(as.vector(Poona$Size))
SaBx<-boxplot(as.vector(Saintpaul$Size))
TyBx<-boxplot(as.vector(Typhimurium$Size))

length(AgBx$out)
length(BrBx$out)
length(JaBx$out)
length(MoBx$out)
length(NeBx$out)
length(PoBx$out)
length(SaBx$out)
length(TyBx$out)


file2<-'/media/ebecerra/2ce97da3-6206-4ea6-a2bd-edaaa8606ac3/home/ebecerra/TESINA/RCode/Pan1526.csv'
NewTypmPan<-read.csv(file2,stringsAsFactors=F)


NewTypmPan[1:10,1:10]
PanMatrix[1:10,1:10]

# throw a away unused levels
# ?droplevels()

gg_info<-NewTypmPan[c('Genomes','Groups')]
write.csv(gg_info,file='ToAddGroupInfo.csv')

Ser_Pan<-PanMatrix[c('Serovar')]
write.csv(Ser_Pan,file='Ser_Pan.csv')

Dduende<-NewTypmPan['duende']
write.csv(Dduende,'DuendeAnnotation.csv')



###################### Feb/15/2017 #########################################


# Adding the Group and the Duende Annotation

file<-'~/ubuntu_ebecerra/2UF/0209Pan/3_2800PanMatrix.csv'
file2<-'~/ubuntu_ebecerra/2UF/0214Coloring/papA+Gr_Annotation.v2.csv'

PanMatrix<-read.csv(file)
MetaToAdd<-read.csv(file2,header=F)

PanMatrix[1:10,1:10]
MetaToAdd[1:10,]
names(MetaToAdd)<-c('Genome','Serovar','Group','papA')

a<-c(1,2,3)
b<-c(2,3,1)
match(a,b)

PanMatrix.2<-cbind(MetaToAdd[match(MetaToAdd$Genome,rownames(PanMatrix)), ][ c('Group' , 'papA')]  ,      PanMatrix) 
dim(PanMatrix.2)
PanMatrix.2[1:10,1:10]

rownames(PanMatrix.2)<-rownames(PanMatrix)

PanMatrix.3<-PanMatrix.2[c    (4,3,1,2,  5:ncol(PanMatrix.2)   )]

PanMatrix.3[1:10,1:10]
write.csv(PanMatrix.3,'PanMatrix.v4.2800.csv')





############################ Tettelin Graph ################################################## 

setwd("/media/ebecerra/2ce97da3-6206-4ea6-a2bd-edaaa8606ac3/home/ebecerra/2UF/0209Pan")

file<-'PanMatrix.v4.2800.csv'
PanMatrix<-read.csv(file)

PanMatrix[1:10,1:10]

li_Sub_Pan<-split(PanMatrix,PanMatrix$Serovar)

names(li_Sub_Pan)
li_Sub_Pan[['Agona']][1:10,1:10]

m<-list()
for( i in 1:length(li_Sub_Pan) ) 
{
  m[[i]]<-li_Sub_Pan[[i]][1:10,c(1,2,3,3000:3999,4000:4999)]
}

toy<-rbind(m[[1]],m[[2]],m[[3]],m[[4]],m[[5]],m[[6]],m[[7]],m[[8]])



?heatmap

ntoy<-as.matrix(toy[,4:ncol(toy)])  
S_ntoy<-colSums(ntoy)
#S_ntoy
S_ntoy[S_ntoy==1]

hist(S_ntoy)

heatmap(ntoy)

install.packages('gplots')
library(gplots)
heatmap.2(ntoy,dendrogram='none', Rowv=FALSE, Colv=FALSE,trace='none')

heatmap(ntoy,Rowv=NULL,Colv=NULL)

heatmap(ntoy,col = c('white','red'), scale="column", margins=c(5,10))

write.csv(toy,'Toy.csv')

####################### Building the model with the model table ############################

setwd("/media/ebecerra/2ce97da3-6206-4ea6-a2bd-edaaa8606ac3/home/ebecerra/2UF/0209Pan")
file<-'Toy.csv'
toy<-read.csv(file)

library(ggplot2)
library(gridExtra)

toy[1:10,1:10]
# Definitions
cols_meta<-3

n_toy<-toy[,-c(1:cols_meta)]
n_toy[1:10,1:10]

df_g3_work<-n_toy

counter <- rep(0, nrow(df_g3_work)) #create empty vector to count pangenome

count_matrix <- function(a){
  #amatrix
  genes_genome <- sum(a) # gives the number og genes in this genome
  b <- counter - a #negative numbers will be new genes
  new_genes <- length(which(b < 0)) #return number of new genes
  counter <<- counter + a  #number != 0 will be total number of genes  
  total_genes <- length(which(counter != 0)) #return total number of genes
  answer <- c(genes_genome, new_genes, total_genes)
  return(answer)
}

resample_count <- function(w){
  resampled <- w[sample(1:nrow(w)),] #creates new pangenome matrix changing order of rows
  counter <<- rep(0, ncol(w))  #clear to zero variable counter after each resampling
  apply(resampled, 1, count_matrix) #apply count_matrix() to new df
}

###running for group 3

# Heavy Step HEAVY WARNING 4 Minutes with toy
results_replicate_g3 <- replicate(1000, resample_count(df_g3_work)) #run resample_count 1000, changing order of genomes each time

head(results_replicate_g3,n = 50)

dim(results_replicate_g3)
#organize  results_replicate_g3 in a matrix 
output_g3 <- cbind.data.frame((data.frame(matrix(unlist(results_replicate_g3), 
                                                 nrow=length(results_replicate_g3)/3, 
                                                 ncol=3, byrow=T),stringsAsFactors=FALSE)), 1:nrow(df_g3_work))

colnames(output_g3) <- c("genes_per_genome", "new_genes", "total_genes", "genome_number")

###################### Power Law Model from Marcos ############################# 

library(poweRlaw)

output_g3[1:10,]

#g3
m_g3 = displ$new(round(tapply(output_g3$total_genes, output_g3$genome_number, mean)))
est_g3 <- estimate_xmin(m_g3)
m_g3$setXmin(est_g3)

m_g3
# WARNING This Command is to heavy with the toy is gonna be 1 hour
bs_g3 <-bootstrap(m_g3, no_of_sims=100, threads=4)

bs_g3$bootstraps
# Just in case save R Data in case of a ReRun
#save.image("g3.RData")


###graphing g3
#create df adding means

graph_g3 <- cbind.data.frame(log2(output_g3[,2]),
                             output_g3$total_genes,
                             as.vector(round(tapply(output_g3$total_genes, output_g3$genome_number, mean))), 
                             log2(as.vector(round(tapply(output_g3$new_genes, output_g3$genome_number, mean)))),
                             1:nrow(df_g3_work))

graph_g3 <- subset(graph_g3, graph_g3$new_genes != -Inf)

colnames(graph_g3) <- c("new_genes", "total_genes","total_mean", "new_mean", "genome_number")

class(graph_g3)
graph_g3

library(ggplot2)

#Saving G3
m_g3
#min 22
#alpha 2.94
mean((bs_g3$bootstraps[,2]))
sd((bs_g3$bootstraps[,2]))
#sd min 3.4

mean((bs_g3$bootstraps[,3]))
sd((bs_g3$bootstraps[,3]))
#sd alpha 0.2

ggplot(data = graph_g3) +
  geom_point(aes(x = genome_number, y = new_genes), size = 0.01, shape = ".") +
  geom_line(aes(x = genome_number, y = new_mean), colour = "red", size = 1.5)+
  scale_x_continuous(breaks = seq(0,300,50), limits = c(0,300)) +
  ylab("New Genes (log2)") +
  xlab("Genome Number") +
  theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size = 1),
        axis.line = element_line(colour = "black",  size = 1),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        axis.title.x = element_text( size = 20),
        axis.title.y = element_text( size = 20),
        axis.text = element_text(size =  17))

#size 612 260

ggplot(data = graph_g3) +
  geom_point(aes(x = genome_number, y = total_genes), size = 0.1, shape = ".") +
  geom_line(aes(x = genome_number, y = total_mean), colour = "blue", size = 1.5) +
  ylab("Total Genes") +
  xlab("Genome Number") +
  scale_x_continuous(breaks = seq(0,300,50), limits = c(0,300)) +
  scale_y_continuous(breaks = seq(3000,15000,3000), limits = c(3000,15000)) +
  theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size = 1),
        axis.line = element_line(colour = "black",  size = 1),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        axis.title.x = element_text( size = 20),
        axis.title.y = element_text( size = 20),
        axis.text = element_text(size =  17))

#############################################################################################################################

setwd("/media/ebecerra/2ce97da3-6206-4ea6-a2bd-edaaa8606ac3/home/ebecerra/2UF/0209Pan")
file<-'Toy.csv'
toy<-read.csv(file)

library(ggplot2)
library(gridExtra)

toy[1:10,1:10]
# Definitions
cols_meta<-3

n_toy<-toy[,-c(1:cols_meta)]
n_toy[1:10,1:10]

df_g3_work<-n_toy

n_toy[1:10,1:10]

counter <- rep(0, nrow(df_g3_work)) #create empty vector to count pangenome

count_matrix <- function(a){
  #amatrix
  genes_genome <- sum(a) # gives the number og genes in this genome
  b <- counter - a #negative numbers will be new genes
  new_genes <- length(which(b < 0)) #return number of new genes
  counter <<- counter + a  #number != 0 will be total number of genes  
  total_genes <- length(which(counter != 0)) #return total number of genes
  answer <- c(genes_genome, new_genes, total_genes)
  return(answer)
}

resample_count <- function(w){
  resampled <- w[sample(1:nrow(w)),] #creates new pangenome matrix changing order of rows
  counter <<- rep(0, ncol(w))  #clear to zero variable counter after each resampling
  apply(resampled, 1, count_matrix) #apply count_matrix() to new df
}

###running for group 3

# Heavy Step HEAVY WARNING 4 Minutes with toy
results_replicate_g3 <- replicate(1000, resample_count(df_g3_work)) #run resample_count 1000, changing order of genomes each time

#organize  results_replicate_g3 in a matrix 
output_g3 <- cbind.data.frame((data.frame(matrix(unlist(results_replicate_g3), 
                                                 nrow=length(results_replicate_g3)/3, 
                                                 ncol=3, byrow=T),stringsAsFactors=FALSE)), 1:nrow(df_g3_work))

colnames(output_g3) <- c("genes_per_genome", "new_genes", "total_genes", "genome_number")


########## Examples from the package #############
########## Data Set Moby #########################


library(poweRlaw)

data('moby',package='poweRlaw')


moby
#### power Law ####
# Construct the object  
m_pl=displ$new(moby)

# Estimate the lower threshold
est=estimate_xmin(m_pl)

# Update the power law object
m_pl$setXmin(est)

# Alternatively, we could perform a parameter scan for each value of xmin
#estimate_xmin(m_pl, pars=seq(1.8, 2.3, 0.1))

m_pl
# RESULTS
# Xmin=7
# Alpha is 1.95

#### log-normal ####
# Construct, estimate and update parameters
m_ln=dislnorm$new(moby)
est=estimate_xmin(m_ln)
m_ln$setXmin(est)

#### poisson ####
m_pois=dispois$new(moby)
est=estimate_xmin(m_pois)
m_pois$setXmin(est)

#### comparasion between pl, ln, pois #### 
plot(m_pl)
lines(m_pl, col=2)
lines(m_ln, col=3)
lines(m_pois, col=4)

#### Uncertaintiy on the parameters ####
# A bootstrap is performed

# Bootstrap of the poweer law regression
bs=bootstrap(m_pl,no_of_sims = 10,threads = 4)
# Standar deviation of the X min
sd(bs$bootstraps[,2])
# SD of alpha
sd(bs$bootstraps[,3])

# Alternatively, we can visualise the results using the plot function:
## trim=0.1 only displays the final 90% of iterations
plot(bs, trim=0.1)
plot(bs)

data(bootstrap_moby)
plot(bootstrap_moby, trim=0.1)
plot(bootstrap_moby)

hist(bs$bootstraps[,2])
hist(bs$bootstraps[,3])
hist(bootstrap_moby$bootstraps[,2])
hist(bootstrap_moby$bootstraps[,3])

# A similar bootstrap analysis can be obtained for the log-normal distribution
bs1 = bootstrap(m_ln,no_of_sims = 20, threads = 4)
plot(bs1, trim=0.1)

bs_p = bootstrap_p(m_pl,threads=4)
plot(bs_p)

#To compare two distributions, each distribution must have the same lower threshold. 
#So we first set the log normal distribution object to have
#the same x min as the power law object
m_ln$setXmin(m_pl$getXmin())

est = estimate_pars(m_ln)
m_ln$setPars(est)
# Then we can compare distributions
comp = compare_distributions(m_pl, m_ln)
# 0.68 Neither model is better 
comp$p_two_sided

xmins = seq(1, 1001, 5)
est_scan = 0*xmins
for(i in seq_along(xmins)) {
  m_pl$setXmin(xmins[i])
  est_scan[i] = estimate_pars(m_pl)$pars
}

plot(est_scan)





