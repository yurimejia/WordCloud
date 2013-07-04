WordCloud
=========

This R program plots a word cloud of the most frequent words 
from tweets retrieved according to a search term.

The main function PlotWordCloud(searchTerm, maxTweets)
takes a search term and a maximum number of tweets to be retrieved; 
and plots the word cloud.

It consists of four steps: 
1 Download necessary packages
2 Get and clean tweets
3 Calculate words' frequencies
4 Plot word cloud

Example: PlotWordCloud("#kitsilano", 100) 
produces the word cloud in kitsWD.png



