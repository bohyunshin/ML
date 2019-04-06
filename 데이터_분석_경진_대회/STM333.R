library(tm)
library(sna)

# document term matrix ¸¸µé±â
sales = read.csv('c:/users/sbh0613/data/1Â÷Á¾ÇÕÀüÃ³¸®.csv',header=T)
names(sales)
dim(sales)
sales.con = paste(sales$¹®ÀÇ°³¿ä,sales$Á¢¼ö³»¿ë)
sales.con = as.matrix(sales.con)
sales.cor = Corpus(VectorSource(sales.con))
sales.dtm = DocumentTermMatrix(sales.cor)
dim(sales.dtm)
inspect(sales.dtm[5883,1:10])

# ¾µµ¥ ¾ø´Â ¸»ÀÌ Á» ¸¹´Ù. ±×·¯¸é °¢ Çà¸¶´Ù ¸í»çÃßÃâÀ» ÇÑ °ÍÀ¸·Î document term matrixÀ» ¸¸µç´Ù¸é??


library(rJava)
library(KoNLP)
library(tm)
library(stringr)

.libPaths()
useSejongDic()
options(mc.cores=1)

setwd('c:/users/sbh0613/data')

sales <- read.csv('1Â÷Á¾ÇÕÀüÃ³¸®.csv',header=T)
content <- sales[,which(names(sales)=='Á¢¼ö³»¿ë')]
content <- as.vector(content)

#¸í»ç ÃßÃâÇÏ¿© ¹éÅÍ¸¦ »Ì¾Æ³»´Â ÇÔ¼ö ¸¸µé±â
words = function(doc){
		if (doc == '' | doc == "['']" | doc == "[' ']"){
		return('')
}
		doc = as.character(doc)
		doc2 = SimplePos22(doc)
		doc3 = str_match(doc2,"[°¡-ÆR]+/NC")
		doc4 = na.omit(doc3)
		for(i in 1:nrow(doc4)){
		doc4[i] = strsplit(doc4[i],'/')[[1]][1]
}
		return(as.vector(doc4))
}

#°¢ Çà¸¶´Ù Á¢¼ö³»¿ë Ä®·³ÀÇ ¸í»ç ÃßÃâÇØ¼­ ¸®½ºÆ®¿¡ ´ã±â.
list.noun = list()
for (i in 1:nrow(sales)){
		list.noun[[i]] = words(content[i])
}


length(list.noun)

fileConn <- file("mydata.txt")
writeLines(sales$Á¢¼ö³»¿ë¸í»çÃßÃâ[1:5883], fileConn)
close(fileConn)

noun.txt = readLines('mydata.txt')

noun.cor = Corpus(VectorSource(noun.txt))
noun.dtm = DocumentTermMatrix(noun.cor)
dim(noun.dtm)
#Â÷¿øÀÌ ÈÎ¾À ÁÙ¾îµé¾ú´Ù!
inspect(noun.dtm)

#term Áß¿¡¼­ 100¹ø ÀÌ»ó ³ª¿Â ¾Öµé¸¸ Ãß·Áº¸¸é 581°³°¡ ³ª¿È. 46000°³ Áß¿¡¼­. °Â³×µé·Î ´Ù½Ã Çà·Ä ¸¸µé¾î º¸±â.
sales.n.m = as.matrix(noun.dtm)

freq.noun = colSums(sales.n.m)

sales.n.m.over.100 = sales.n.m[,freq.noun>1000]

dim(sales.n.m.over.100)


#pca »ìÂ¦ ÇØº¸±â
sales.pca = prcomp(sales.n.m.over.100,center=TRUE,scale=TRUE)

plot(sales.pca,type='l')

summary(sales.pca)

????




# correlation matrixÀ» ÀÌ¿ëÇÏ¿© network ½Ã°¢È­ ÇØº¸±â.

library(qgraph)

cormat = cor(sales.n.m.over.100)

#ÇÑ±¹¾î Ä®·³ ¿µ¾î·Î ¹Ù²ãÁÖ±â

fileconnet = file('colnames.txt')
writeLines(colnames(cormat),fileconnet)
close(fileconnet)

english.name = readLines('colnames.txt')
english.name = english.name[-1]

cormat.eng = cormat

colnames(cormat.eng) = english.name
rownames(cormat.eng) = english.name

corr.net = qgraph(cormat.eng, minimum=0.3, vsize=4,layout='spring', labels = row.names(cormat.eng))
#centrality
a node is central / important / influential if..
- it has many connections (degree / strength)
- it is close to all other nodes (closeness)
- it connects other nodes (betweenness)

# degree »ìÆìº¸±â

cent.corr = centrality(corr.net)

as.data.frame(sort(cent.corr$OutDegree,decreasing=TRUE))

# degree °¡Àå ³ôÀº 3°³·Î ´ÙÁß ¼±Çü È¸±Í ½Ç½ÃÇÏ±â

sales.term = as.data.frame(sales.n.m.over.100)
names(sales.term) = colnames(sales.n.m.over.100)

sales.marketing = sales.term[c('È«º¸','¼ö¸³', '¹æ¾È', 'ÃßÁø', '¸ÅÃ¼', 'È°¿ë', '¿ÀÇÁ¶óÀÎ', '¿Â¶óÀÎ', 'Á¦ÀÛ', '±âÈ¹', 'ÁÖ¿ä')]
sales.planning = sales.term[c('±âÈ¹','¼ö¸³', 'È«º¸', 'Á¦ÀÛ', 'ÀÌº¥Æ®', 'ÄÜÅÙÃ÷', '¿î¿µ', '°ü¸®', '´ë»ó')]
sales.making = sales.term[c('Á¦ÀÛ','È«º¸', 'È°¿ë', '¿Â¶óÀÎ', 'ÀÌº¥Æ®', 'ÄÜÅÙÃ÷', '¿î¿µ', '°ü¸®', '±âÈ¹')]

fit.marketing = lm(È«º¸~. , data=sales.marketing)
summary(fit.marketing)

fit.planning = lm(±âÈ¹~., data=sales.planning)
summary(fit.planning)

fit.making = lm(Á¦ÀÛ~., data=sales.making)
summary(fit.making)

# success ¸í»ç »ìÆìº¸±â

success.index = which(sales$°á°ú == 'success')


suc.df = data.frame(x=rep(0,length(success.index)))
for (i in 1:length(success.index)){
suc.df$x[i] = toString(list.noun[[success.index[i]]])
}


file.suc = file("success.txt","w")
for (i in 1:1022){
write(suc.df$x[i],file.suc,append=TRUE)
}
close(file.suc)

list.noun.success = readLines("success.txt")

noun.cor.suc = Corpus(VectorSource(list.noun.success))
noun.dtm.suc = DocumentTermMatrix(noun.cor.suc)
dim(noun.dtm.suc)
inspect(noun.dtm.suc)


#term Áß¿¡¼­ 100¹ø ÀÌ»ó ³ª¿Â ¾Öµé¸¸ Ãß·Áº¸¸é 70°³°¡ ³ª¿È. 12349°³ Áß¿¡¼­. °Â³×µé·Î ´Ù½Ã Çà·Ä ¸¸µé¾î º¸±â.
sales.suc = as.matrix(noun.dtm.suc)

freq.noun.suc = colSums(sales.suc)

sales.suc.100 = sales.suc[,freq.noun.suc>100]

dim(sales.suc.100)

sales.suc.100[1:5,1:10]

cormat.suc = cor(sales.suc.100)

cormat.suc[1:5,1:5]
corr.suc = qgraph(cormat.suc, minimum=0.3, vsize=4,layout='spring', labels = row.names(cormat.suc),filetype="jpeg")


cent.suc = centrality(corr.suc)

as.data.frame(sort(cent.suc$OutDegree,decreasing=TRUE))


# cancelled, failed, holding, pending, tie-in failed ¸í»ç »ìÆìº¸±â

fail.index = which(sales$°á°ú == 'cancelled' | sales$°á°ú == 'failed' | sales$°á°ú == 'holding' | sales$°á°ú ==  'pending' | sales$°á°ú == 'tie-in failed')  

fail.df = data.frame(x=rep(0,length(fail.index)))
for (i in 1:length(fail.index)){
fail.df$x[i] = toString(list.noun[[fail.index[i]]])
}


file.fail = file("fail.txt","w")
for (i in 1:1308){
write(fail.df$x[i],file.fail,append=TRUE)
}
close(file.fail)

list.noun.fail = readLines("fail.txt")

noun.cor.fail = Corpus(VectorSource(list.noun.fail))
noun.dtm.fail = DocumentTermMatrix(noun.cor.fail)
dim(noun.dtm.fail)
inspect(noun.dtm.fail)

#term Áß¿¡¼­ 100¹ø ÀÌ»ó ³ª¿Â ¾Öµé¸¸ Ãß·Áº¸¸é 70°³°¡ ³ª¿È. 12349°³ Áß¿¡¼­. °Â³×µé·Î ´Ù½Ã Çà·Ä ¸¸µé¾î º¸±â.
sales.fail = as.matrix(noun.dtm.fail)

freq.noun.fail = colSums(sales.fail)

sales.fail.100 = sales.fail[,freq.noun.fail>150]

dim(sales.fail.100)

cormat.fail = cor(sales.fail.100)
corr.fail = qgraph(cormat.fail, minimum=0.3, vsize=4,layout='spring', labels = row.names(cormat.fail),filetype="jpeg")


cent.fail = centrality(corr.fail)

as.data.frame(sort(cent.fail$OutDegree,decreasing=TRUE))

unique(sales$°á°ú)

save.image()

# ºĞ¼®,È°¿ë¿¡ ´ëÇÑ È¸±ÍºĞ¼®
sales.suc.term = as.data.frame(sales.suc.100)
names(sales.suc.term) = colnames(sales.suc.term)


sales.ºĞ¼® = sales.suc.term[c('ºĞ¼®', 'ÀÌ½´', '±âÈ¹', 'Á¦ÀÛ', '½ÇÇà', 'ÀÌº¥Æ®', 'Á¦½Ã', 'È«º¸', 'È°¿ë', 'ÁÖ¿ä', '¼ö¸³')]
sales.È°¿ë = sales.suc.term[c('È°¿ë', 'ÁÖ¿ä', '¼ö¸³', 'ºĞ¼®', 'Á¦ÀÛ', 'È«º¸', 'Á¦½Ã', 'Àü·«', '¸ÅÃ¼', '°ü·Ã')]


lm.ºĞ¼® = lm(ºĞ¼®~. , data=sales.ºĞ¼®)
summary(lm.ºĞ¼®)

lm.È°¿ë = lm(È°¿ë~. , data=sales.È°¿ë)
summary(lm.È°¿ë)

¿¢¼¿ ÆÄÀÏ¿¡¼­, csv ÆÄÀÏ·Î ÀúÀåÇÒ ¶§ ¹º°¡ ÀÎÄÚµù ¿À·ù°¡ ³­ °Í °°´Ù.
csv ÆÄÀÏ·Î ÀúÀåÇØ¼­ r¿¡¼­ read.csv·Î ºÒ·¯¿ÔÀ» ¶§, ¿©±â¿¡ ÀÖ´Â µ¥ÀÌÅÍ¸¦ ±×´ë·Î ¾²¸é
ÀÎÄÚµù ¿À·ù°¡ ³ª´Âµ¥,
¾ê¸¦ ´Ù½Ã txt ÆÄÀÏ¿¡ ¾²°í ¾ê¸¦ ´Ù½Ã ±×´ë·Î ºÒ·¯¿À¸é ¿À·ù°¡ ¾ø´Ù.
