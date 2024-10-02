Create Database Spotify_DB

Use Spotify_DB

Select * From [Spotify Most Streamed Songs]

		/* Basic Insights: */

--Q1: Top 10 most streamed songs on Spotify

Select top 10 track_name
	,artist_s_name
	,streams
From [Spotify Most Streamed Songs]
Order by streams desc

--Q2: Which song is featured in the highest number of Spotify playlists?

Select top 1 track_name
	,artist_s_name
	,in_spotify_playlists
From [Spotify Most Streamed Songs]
Order by 3 desc

--Q3: List all songs released in 2023 that are in the top 50 on both Spotify and Apple charts

Select track_name
	,artist_s_name
	,released_year
	,in_spotify_charts
	,in_apple_charts
From [Spotify Most Streamed Songs]
Where released_year = 2023 and in_apple_charts between 1 and 50 and in_spotify_charts between 1 and 50
Order by in_spotify_charts asc

		/* Trend Analysis: */

--Q1: What is the trend in the number of streams for songs released between 2020 and 2023?

Select released_year
	,avg(streams) as 'AverageStreams'
From [Spotify Most Streamed Songs]
Where released_year between 2020 and 2023
Group by released_year
Order by 1 asc

--Q2: How has the average BPM (beats per minute) of top-charting songs changed over the years?

Select released_year 
	,avg(bpm) as 'AvgBPM'
From [Spotify Most Streamed Songs]
Group by released_year
Order by 1 asc

--Q3: What is the correlation between the song’s release year and its number of streams on Spotify?

Select released_year 
	,Format(Round(avg(streams) + 0.255, 2), '#,###,###') as 'AvgStreams'
From [Spotify Most Streamed Songs]
Group by released_year
Order by 1 asc

		/* Musical Attributes and Popularity: */

--Q1: Find the top 5 songs with the highest danceability percentage

Select top 10 track_name
	,artist_s_name
	,danceability
From [Spotify Most Streamed Songs]
Order by danceability desc

--Q2: What are the average valence and energy levels of songs in the top 100 Spotify charts?

Select top 100 in_spotify_charts
	,avg(valence) as 'AvgValence'
	,avg(energy) as 'AvgEnergy'
From [Spotify Most Streamed Songs]
Group by in_spotify_charts
Order by in_spotify_charts asc

--Q3: Is there a relationship between energy percentage and streams? (You can look at correlation or grouping streams by energy ranges.)

Select energy
	,Format(Round(avg(streams) + 0.255, 2), '#,###,###') as 'AvgStreams'
From [Spotify Most Streamed Songs]
Group by energy
Order by energy asc

		/* Cross-Platform Comparison: */

--Q1: Which songs appear in both the Spotify and Apple playlists?

Select track_name
	,artist_s_name
From [Spotify Most Streamed Songs]
Where in_spotify_playlists > 0 and in_apple_playlists > 0
Order by in_spotify_playlists desc

--Q2: What is the average ranking of songs on Deezer charts compared to their Spotify chart rankings?

Select avg(in_deezer_charts) as 'AverageDeezerChart'
	,avg(in_spotify_charts) as 'AverageSpotifyChart'
From [Spotify Most Streamed Songs]

--Q3: Identify songs that are in the top 10 on Shazam but do not appear in the top 50 on Spotify.

Select track_name
	,artist_s_name
	,in_shazam_charts
	,in_spotify_charts
From [Spotify Most Streamed Songs]
Where in_shazam_charts <= 10 and in_spotify_charts > 50

		/* Advanced Insights: */ 

--Q1: Does the number of contributing artists (artist_count) affect the song's popularity on Spotify?

Select artist_count
	,Format(Round(avg(streams) + 0.255, 2), '#,###,###') as 'AvgStreams'
From [Spotify Most Streamed Songs]
Group by artist_count
Order by 1 asc

--Q2: Which key is the most common among the top 100 streamed songs?

Select [key]
	,count(*) as 'Count'
From [Spotify Most Streamed Songs]
Where in_spotify_charts <= 100 and [key] is not null
Group by [key]
Order by 2 desc

--Q3: Analyze the relationship between acousticness percentage and the number of streams

Select acousticness
	,Format(Round(avg(streams) + 0.255, 2), '#,###,###') as 'AvgStreams'
From [Spotify Most Streamed Songs]
Group by acousticness
Order by acousticness desc

--Q4: What top 5 artists have the most streamed songs?

Select top 5 artist_s_name
	,Format(Round(sum(streams) + 0.255, 2), '#,###,###') as 'TotalStreams'
From [Spotify Most Streamed Songs]
Group by artist_s_name
Order by sum(streams) desc