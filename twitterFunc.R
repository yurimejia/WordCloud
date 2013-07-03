#EnsurePackage(x) - Installs and loads package "x" if necessary
EnsurePackage <- function(x)
{
  x <- as.character(x)
  if (!require(x,character.only=TRUE))
  {
    install.packages(pkgs=x, repos="http://cran.r-project.org")
    require(x,character.only=TRUE)
  }
}

#PrepareTwitter() - Loads packages for working with twitteR
#tm, wordcloud and stringr
PrepareTwitter <- function()
{
  EnsurePackage("bitops")
  EnsurePackage("RCurl")
  EnsurePackage("RJSONIO")
  EnsurePackage("twitteR")  
  EnsurePackage("tm")
  EnsurePackage("wordcloud")   
  EnsurePackage("stringr")
}
  
Login <- function()
{
  load("~/OAuth.RData")
  registerTwitterOAuth(oauth)
}

#TweetFrame() - Returns a dataframe based on a search of Twitter.
TweetFrame <- function(searchTerm, maxTweets)
{
  #Get tweets as a List
  tweetList <- searchTwitter(searchTerm, n=maxTweets)
  
  #Create a rectangular Data Frame out of tweetList, using:
  #as.data.frame() - Coerces eash list element into a row
  #lapply() - Applies this to all of the elements in tweetList
  #rbind() - Takes all of the rows and puts them together
  #do.call() - Gives rbind() all the rows as individual elements
  tweetDF <- do.call("rbind", lapply(tweetList,as.data.frame))
  
  #Order tweetDF according to creation date
  tweetDF <- tweetDF[order(as.integer(tweetDF$created)),] 
  
  return(tweetDF)
}  

# CleanTweets() - Takes the junk out of a vector
# of tweet texts
CleanTweets<-function(tweets)
{
  # Remove redundant spaces
  tweets <- str_replace_all(tweets,"  "," ")
  # Get rid of URLs
  tweets <- str_replace_all(tweets,"http[s]*://t.co/[a-z,A-Z,0-9,\\.]{10}","")
  tweets <- str_replace_all(tweets,"http[s]*://t.co/[a-z,A-Z,0-9]{7}","")
  # Take out retweet header, there is only one
  tweets <- str_replace(tweets,"RT @[a-z,A-Z,0-9,_]*: ","")
  # Get rid of hashtags
  tweets <- str_replace_all(tweets,"#[a-z,A-Z,0-9]*","")
  # Get rid of references to other screennames
  tweets <- str_replace_all(tweets,"@[a-z,A-Z,0-9,_]*","")
  # Get rid of hexadecimal characters
  tweets <- str_replace_all(tweets,"[\x01-\x1f\x7f-\xff]","")
  return(tweets)  
}



#GetTextReady() - Takes a hashtag & n, 
#retrieves n tweets from twitter and 
#returns them cleaned
GetTextReady <- function(hashtag, n)
{
  tweetDF <- TweetFrame(hashtag, n)
  cleanText <- tweetDF$text
  cleanText <- CleanTweets(cleanText)
  return(cleanText)
}

#WordCloud() - Takes cleanText
#and prints a wordcloud of most frequent words
WordCloud <- function(cleanText)
{  
  tweetCorpus <- Corpus(VectorSource(cleanText))
  tweetCorpus <- tm_map(tweetCorpus, tolower)
  tweetCorpus <- tm_map(tweetCorpus, removePunctuation)
  tweetCorpus <- tm_map(tweetCorpus, removeWords, stopwords('english'))  
  tweetTDM <- TermDocumentMatrix(tweetCorpus)
  tdMatrix <- as.matrix(tweetTDM)
  sortedMatrix <- sort(rowSums(tdMatrix), decreasing=TRUE)
  cloudFrame <- data.frame(word = names(sortedMatrix), freq = sortedMatrix)
  wordcloud(cloudFrame$word, cloudFrame$freq)        
}


