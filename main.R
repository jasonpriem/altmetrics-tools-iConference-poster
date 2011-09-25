library(ggplot2)
library(reshape)
library(plyr)
library(gdata)

# get the data
ti <- read.table("/home/jason/projects/altmetrics-tools/data/total-impact-results_20110922.txt", sep="\t", header=T)
names(ti)[1] <- "doi"
names(ti)
nrow(ti)

ci <- read.table("/home/jason/projects/altmetrics-tools/data/citedin-results.csv", sep=",", header=T)
names(ci)
nrow(ci)

doi2pmid <- read.table("/home/jason/projects/altmetrics-tools/data/doi2pmid.csv", sep=",", header=F)
names(doi2pmid) <- c("doi", "pmid")

# sanity checks
nrow(ti)
nrow(ci)
nrow(doi2pmid)
nrow(doi2pmid[!is.na(doi2pmid$pmid),])
ti[!(ti$doi %in% doi2pmid$doi),]


# TI data
###################################################
# a few categories have NAs where they should have zeroes...pretty sure that the articles were looked up.
ti$Delicious_bookmarks[is.na(ti$Delicious_bookmarks)] <- 0
ti$Mendeley_groups[is.na(ti$Mendeley_groups)] <- 0
ti$Mendeley_readers[is.na(ti$Mendeley_readers)] <- 0

# remove columns
df <- melt(ti)
df <- subset(df, !(variable %in% c("PubMed_year", "Mendeley_year", "Dryad_year", "CrossRef_year"))) # dates


posvars <- subset(ddply(df, .(variable), summarise, max=max(value, na.rm=TRUE)), max > 0)$variable # get variables with any values > 0
df <- subset(df, variable %in% posvars) # remove variables without any values > 0.

# relevel factors, reorder categories
df$variable <- factor(df$variable)
df$variable <- reorder(df$variable, new.order=c("CiteULike_bookmarks", "Mendeley_readers", "Mendeley_groups", "Delicious_bookmarks", "Wikipedia_article_mentions", "PubMed_citations_in_pmc", "Dryad_total_file_views", "Dryad_total_downloads", "Dryad_package_views", "PlosAlm_CrossRef", "PlosAlm_Scopus", "PlosAlm_Research.Blogging", "PlosAlm_Postgenomic", "PlosAlm_Connotea", "PlosAlm_PLoS_xml_views", "PlosAlm_PLoS_pdf_views", "PlosAlm_PLoS_html_views"))
df <- df[!is.na(df$variable),]

# rescale: normalise by max and min for each category
df <- ddply(df, .(variable), transform, rescale=rescale(value))

# now we order the articles by mean rescaled value in all categories. We don't use the PLoS categories in the mean, though, since that's just one publisher.
df$rescale.no.alm <- df$rescale
df$rescale.no.alm[grep("Plos", df$variable)]<-NA
act <- ddply(df, .(doi), summarise, activity=mean(rescale.no.alm, na.rm=TRUE))
df$doi <- reorder(df$doi, new.order=rev(order(act$activity)))

ggplot(df, aes(variable, doi)) + geom_tile(aes(fill=rescale)) + coord_flip() + scale_fill_gradient(low="white", high="steelblue") + scale_x_discrete(expand=c(0,0)) + scale_y_discrete(expand=c(0,0), breaks=NA) + labs(x="", y="") + theme_grey(base_size=10) + opts(axis.ticks=theme_blank(), axis.text.x=theme_blank(), legend.position="none", panel.grid.major=theme_blank(), panel.grid.minor=theme_blank(), panel.background=theme_rect(fill="white"), panel.border=theme_rect(colour="#666666"))

# % articles with at least one event
nrow(subset(ddply(df, .(doi), summarise, total.events=sum(value, na.rm=TRUE)), total.events > 0)) / nrow(ti)

# median and mean numbers of events per article
df$value.no.alm <- df$value
df$value.no.alm[grep("Plos", df$variable)]<-NA
events.sum <- ddply(df, .(doi), summarise, count=sum(value.no.alm, na.rm=TRUE))
events.sum
summary(events.sum$count)


# CI data
###################################################
ci$Title <- NULL
ci$PMID <- factor(ci$PMID)

# prep data
cdf <- melt(ci)
posvars <- subset(ddply(cdf, .(variable), summarise, max=max(value, na.rm=TRUE)), max > 0)$variable # get variables with any values > 0
cdf <- subset(cdf, variable %in% posvars) # remove variables without any values > 0.
cdf$variable <- factor(cdf$variable)
cdf$variable <- reorder(cdf$variable, new.order=c("Mendeley", "CiteULike", "Connotea", "NatureBlogs", "GoogleBlogs", "GoogleBooks", "PubmedSub", "Zfin", "Jaspar", "ChdWiki", "cancerCell", "Regtransbase"))
levels(cdf$variable)


# rescale and vis
cdf <- ddply(cdf, .(variable), transform, rescale=rescale(value))
act <- ddply(cdf, .(PMID), summarise, activity=mean(rescale, na.rm=TRUE))

cdf$PMID <- reorder(cdf$PMID, new.order=rev(order(act$activity)))


ggplot(cdf, aes(variable, PMID)) + geom_tile(aes(fill=rescale)) + coord_flip() + scale_fill_gradient(low="white", high="steelblue") + scale_x_discrete(expand=c(0,0)) + scale_y_discrete(expand=c(0,0), breaks=NA) + labs(x="", y="") + theme_grey(base_size=10) + opts(axis.ticks=theme_blank(), axis.text.x=theme_blank(), legend.position="none", panel.grid.major=theme_blank(), panel.grid.minor=theme_blank(), panel.background=theme_rect(fill="white"), panel.border=theme_rect(colour="#666666"))

# % articles with at least one event
nrow(subset(ddply(cdf, .(PMID), summarise, total.events=sum(value, na.rm=TRUE)), total.events > 0)) / nrow(ci)

# median and mean numbers of events per article
events.sum <- ddply(cdf, .(PMID), summarise, count=sum(value, na.rm=TRUE))
events.sum
summary(events.sum$count)










