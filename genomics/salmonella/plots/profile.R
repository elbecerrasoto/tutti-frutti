tn_lib <- read.csv("MZ1597_MZ1838_Tomatoes_norm_for_Max.csv")
df_CDS <- subset(tn_lib, tn_lib$Feature_type == "CDS")



cores <- function(arg1){
  if (arg1 <= 0.01){
    colores <- "magenta"
  } else {
    colores <- "azure4"
  }
  return(colores)
}

cores_vector <- sapply(as.vector(df_CDS$MZ1838_Tomato_FDR), cores)

df_CDS2 <- data.frame(df_CDS$MZ1838_start,
                      as.numeric(levels(df_CDS$MZ1838_Tomato_logFC))[df_CDS$MZ1838_Tomato_logFC],
                      cores_vector)
colnames(df_CDS2) <- c("Start", "FC", "Cores")

graph1 <- ggplot(df_CDS2, aes(x =Start, y = FC, colour= Cores)) +
  geom_point(size = 1) +
  geom_point(shape = 19) +
  theme_bw()

graph1 + scale_colour_manual(values = c("azure4", "magenta")) + theme(legend.position="none")



####subset only present in Newport

## convert factor to numeric
as.numeric.factor <- function(x) {as.numeric(levels(x))[x]}


only_C42 <- tn_lib[!(is.na(tn_lib$MZ1838_Length)),]
only_C42_0.1 <- subset(only_C42, as.numeric.factor(only_C42$MZ1838_Tomato_FDR) < 0.1)
only_C42_0.1 <- only_C42[(as.numeric.factor(only_C42$MZ1838_Tomato_FDR) < 0.1),]

only_C42_CDS <- subset(only_C42, only_C42$Feature_type == "CDS" | only_C42$Feature_type == "CDS?") #5786
only_C42_CDS_0.1 <- subset(only_C42_CDS, as.numeric.factor(only_C42_CDS$MZ1838_Tomato_FDR) < 0.1) #931
only_C42_CDS_0.1_negative <- subset(only_C42_CDS_0.1, as.numeric.factor(only_C42_CDS_0.1$MZ1838_Tomato_logFC) < 0) #914
only_C42_CDS_0.1_positive <- subset(only_C42_CDS_0.1, as.numeric.factor(only_C42_CDS_0.1$MZ1838_Tomato_logFC) > 0) #17

#how many unique CDS
which(only_C42_CDS$Unique_to_MZ1838 == "No")

