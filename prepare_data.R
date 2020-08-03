library(stylo)

## Data
selected_features = c("et", "in", "non", "ut", "ad", "cum", "ab", "sed", "ex", "si", "de", "etiam", "enim",
                      "aut", "ac", "nec", "per", "atque", "nam", "uel", "ne", "quidem", "autem", "tamen",
                      "neque", "uero", "ita", "iam", "quoque", "nihil", "pro", "modo", "quia", "quasi",
                      "inter", "nisi", "tunc", "post", "sic", "igitur", "tam", "qua", "ante", "an", "nunc",
                      "apud", "magis", "sine", "ergo", "at", "deinde", "ubi", "dum", "semper", "minus",
                      "unde", "contra", "maxime", "itaque", "sicut", "satis", "denique", "ob", "simul", "uti",
                      "sub", "saepe", "quamquam", "numquam", "ideo", "propter", "siue", "quippe", "prius",
                      "adhuc", "quoniam", "usque", "inde", "bene", "sane", "mox", "item", "super", "quin",
                      "adeo", "quamuis", "cur", "tamquam", "postea", "praeterea", "potius", "statim", "uelut",
                      "postquam", "supra", "ceterum", "certe", "omnino", "licet", "forte", "o", "circa",
                      "rursus", "tandem", "diu", "praeter", "umquam", "tot", "ibi", "hinc", "haud", "necesse",
                      "melius", "paene", "fere", "namque", "amplius", "uix", "scilicet", "quum", "iterum",
                      "aliquando", "aduersus", "seu", "parum", "plerumque", "interim", "prope", "plus", "intra",
                      "partim", "olim", "iuxta", "ultra", "male", "quare", "aliter", "dolorem", "fortasse",
                      "malis", "primis", "studio", "agere", "immo", "quanto", "domine", "eiusdem", "opera",
                      "oportet", "publicam", "tota", "usus", "aetatis", "boni", "locis", "plurimum", "potestate",
                      "saepius", "antea", "demum", "dolore", "imperatori", "latine", "malo", "potuit", "quadam",
                      "quondam", "quosdam", "sumus", "dicuntur", "diuina", "lege", "ordinem", "postremo",
                      "regnum", "solet", "tribus", "fama", "patre", "putat", "hi", "iubet", "pluribus",
                      "quarum", "sancti", "solus", "uera", "uirtutes", "uolunt", "annis", "dicam", "dicta",
                      "domi", "homo", "ingenio", "militum", "studiis", "uoce", "a", "aetate", "castra",
                      "exercitum", "genera", "maior", "summum", "equidem", "eundem", "gratiam", "loci",
                      "magnum", "naturam", "num", "profecto", "amicis", "consules", "etsi", "honore",
                      "honorem", "multos", "quidquid", "quisquam", "dein", "mali", "mecum", "sapientia",
                      "uiginti", "accepit", "cuiusque", "exercitu", "fuisset", "plura", "secum", "domus",
                      "oratio", "principis", "uirtutis", "iter", "liberos", "modi", "ualde", "alioquin",
                      "aqua", "augusti", "locus")

raw.corpus <- load.corpus(files = 'all',
                         corpus.dir = 'corpus_new/',
                         encoding = 'UTF-8')
tokenised_corpus <- txt.to.words.ext(
    raw.corpus,
    corpus.lang = "Latin.corr",
    preserve.case = F)
sliced_corpus <- make.samples(tokenised_corpus,
                             sampling = 'normal.sampling',
                             sample.size = 3000)
freqs <- make.table.of.frequencies(sliced_corpus,
                                   features = selected_features,
                                   relative = F)
rest.freqs  <- 3000 - rowSums(freqs)
all.freqs   <- cbind(freqs[1:nrow(freqs),1:ncol(freqs)], rest.freqs)
all.freqs.p <- matrix(nrow = nrow(all.freqs), ncol = ncol(all.freqs))
rownames(all.freqs.p) <- rownames(all.freqs)
colnames(all.freqs.p) <- colnames(all.freqs)
for (i in 1:nrow(all.freqs))
    for (j in 1:ncol(all.freqs))
        all.freqs.p[i,j] <- all.freqs[i,j]/3000

write.csv(all.freqs.p, "relative_freqs.csv")
