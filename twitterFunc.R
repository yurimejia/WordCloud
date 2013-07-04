# EnsurePackage(x) - Installs and loads package "x" (if necessary)
EnsurePackage <- function(x)
{
  x <- as.character(x)
  if (!require(x,character.only=TRUE))
  {
    install.packages(pkgs=x, repos="http://cran.r-project.org")
    require(x,character.only=TRUE)
  }
}

# PrepareTwitter() - Loads necessary packages 
PrepareTwitter <- function()
{
  EnsurePackage("bitops")
  EnsurePackage("RCurl")
  EnsurePackage("RJSONIO")
  EnsurePackage("twitteR")  
  EnsurePackage("tm")
  EnsurePackage("wordcloud")   
  EnsurePackage("stringr")
  EnsurePackage("RColorBrewer")
}

# Enables R to retrieve tweets from twitter
Login <- function()
{
  load("~/OAuth.RData")
  registerTwitterOAuth(oauth)
}

# TweetsFrame() - Takes a search term and the maximum number of tweets.
# Returns a data frame with retrieved tweets
TweetsFrame <- function(searchTerm, maxTweets)
{
  # Get tweets as a List
  tweetList <- searchTwitter(searchTerm, n=maxTweets)
  
  # Create a rectangular data frame out of tweetList
  tweetDF <- do.call("rbind", lapply(tweetList,as.data.frame))
  
  # Order tweetDF according to creation date
  tweetDF <- tweetDF[order(as.integer(tweetDF$created)),] 
  
  return(tweetDF)
}  

# CleanTweets() - Takes a vector containig tweets' text and
# returns same vector with cleaned text.
CleanTweets<-function(tweets)
{
  # Remove redundant spaces
  tweets <- str_replace_all(tweets,"  "," ")  
  # Get rid of URLs 
  tweets <- str_replace_all(tweets,"http[s]*://t.co/[a-z,A-Z,0-9]{10}","")  
  tweets <- str_replace_all(tweets,"http[s]*://t.co/[a-z,A-Z,0-9]{7}","")  
  # Take out retweet header, there is only one
  tweets <- str_replace(tweets,"RT @[a-z,A-Z,0-9,_]*: ","")
  # Get rid of hashtags
  tweets <- str_replace_all(tweets,"#[a-z,A-Z,0-9,_]*","")
  # Get rid of references to other screennames
  tweets <- str_replace_all(tweets,"@[a-z,A-Z,0-9,_]*","")
  # Get rid of &amp
  tweets <- str_replace_all(tweets,"&amp","")
  # Get rid of hexadecimal characters
  tweets <- str_replace_all(tweets,"[\x01-\x1f\x7f-\xff]","")  
  return(tweets)  
}



# PlotWordCloud() - Takes a search term and a maximum number of tweets.
# Plots a wordcloud of the most frequent words in these tweets 
# (the higher the frequency, the bigger the word).
PlotWordCloud <- function(searchTerm, maxTweets)
{ 
  #-----Loading necessary packages------
  PrepareTwitter()
  Login()
  
  
  #-----Getting tweets ready------
  
  # Get tweets
  tweetDF <- TweetsFrame(searchTerm, maxTweets)    
  # Clean tweets' text from hashtags, retweets, urls, etc.
  cleanText <- CleanTweets(tweetDF$text)    
  
  # Convert tweets to Corpus class, 
  # this allows us to do further cleaning of data.
  tweetCorpus <- Corpus(VectorSource(cleanText))
  # Convert text to lower case
  tweetCorpus <- tm_map(tweetCorpus, tolower)
  # Remove punctuation from text
  tweetCorpus <- tm_map(tweetCorpus, removePunctuation)
  # Remove stop words like: and, on, in, the, etc., in several languages.
  tweetCorpus <- tm_map(tweetCorpus, removeWords, stopwords('english'))
  tweetCorpus <- tm_map(tweetCorpus, removeWords, stopwords('spanish'))
  tweetCorpus <- tm_map(tweetCorpus, removeWords, stopwords('french'))  
  
  
  #-----Calculate frequencies------
  
  # Make a matrix whose entry (i,j) indicates the number of times 
  # that word i appears in tweet j.  
  tweetTDM <- TermDocumentMatrix(tweetCorpus)
  tdMatrix <- as.matrix(tweetTDM)  
  
  # Compute words' frequency by adding entries in each row,
  # and order words from high freq to low freq.
  sortedMatrix <- sort(rowSums(tdMatrix), decreasing=TRUE)      
  # Save words and computed frequencies in a data frame
  cloudFrame <- data.frame(word = names(sortedMatrix), freq = sortedMatrix)   
  
  
  #-----Display wordcloud------
  
  # Set up text color (Red-Purple).
  palette <- brewer.pal(9,"RdPu")
  palette <- palette[-(1:4)] 
  # Plot word cloud.
  wordcloud(cloudFrame$word, cloudFrame$freq, scale=c(4,.3),,max.words=25,random.order=FALSE,,rot.per=.25,colors=palette)
}

