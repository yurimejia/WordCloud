WordCloud
=========

This R script plots a word cloud of the most frequent words 
from tweets retrieved according to a hashtag.

The main function PlotWordCloud(searchTerm, maxTweets)
takes a search term (or hashtag) and a maximum number of tweets to retrieve,
and plots the word cloud.

It follows four steps: 
1 Download necessary packages.
2 Get and clean tweets
3 Calculate words' frequencies
4 Plot word cloud

For example:
PlotWordCloud("#kitsilano", 100)
produces the word cloud in kitsWD.svg



