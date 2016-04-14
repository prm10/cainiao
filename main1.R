item_feature1 <- read.csv("E:/github/cainiao/data/item_feature1.csv", header=FALSE)
x<-item_feature1[30]
ds<-lapply(lapply(item_feature1[1], as.character), function(x) as.Date(x,format="%Y%m%d"))

# as.Date("20141009", format="%Y%m%d")

# plot(ds,x)
