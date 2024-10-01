Create Database SQL_Nba_DB

Use SQL_Nba_DB

Select Distinct * From Nba_Players_Data

			/* Player Performance & Career Analysis: */

--Q1: The top 5 players by average points in a particular season?

Select Top 5 player_name
	,team_abbreviation
	,FORMAT(pts, '#.#') as 'AveragePoints'
	,season
From Nba_Players_Data
Order by pts desc

--Q2: Career Longevity vs. Performance: How does career length (total games played) relate to the player's average points, rebounds, or assists?

Select Distinct top 10player_name
	,SUM(gp) as 'TotalGames'
	,AVG(pts) as 'AveragePoints'
From Nba_Players_Data
Group by player_name
Having SUM(gp) > 1000
Order by AveragePoints desc

Select Distinct player_name
	,SUM(gp) as 'TotalGames'
	,AVG(pts) as 'AveragePoints'
From Nba_Players_Data
Group by player_name
Having SUM(gp) > 1400
Order by TotalGames desc

--Q3: Rookie vs. Veteran Comparison: What are the differences in performance between rookies (under 22 year old) and veterans (players over 30 year old)?

Select player_name
	,age
	,Avg(pts) as 'AveragePoints'
From Nba_Players_Data
Where age < 22 AND pts > 1
Group by player_name, age
Order by AveragePoints desc

Select player_name
	,age
	,Avg(pts) as 'AveragePoints'
From Nba_Players_Data
Where age > 30 AND pts > 1
Group by player_name, age
Order by AveragePoints desc

Select Avg(pts) as 'AveragePoints'
From Nba_Players_Data
Where age < 22 AND pts > 1
Order by AveragePoints desc

	/* Average Point for rookies is 7.9 */

Select Avg(pts) as 'AveragePoints'
From Nba_Players_Data
Where age > 30 AND pts > 1
Order by AveragePoints desc

	/* Average Point for veterans is 8.1 */

--Q4: Draft Position Impact: Is there a correlation between draft position (round/pick number) and a player's career success?

Select draft_round
	,Format(AVG(pts), '#.#') as 'AveragePoints'
	,Format(Avg(reb), '#.#') as 'AverageRebounds'
	,Format(Avg(ast), '#.#') as 'AverageAssists'
From Nba_Players_Data
Where draft_round In(1,2)
Group by draft_round
Order by 1 asc

	/* First round picks averages 10.2 points, 4.3 rebounds, 2.2 assists
	   Second round picks averages 6.3 points, 2.9 rebounds, 1.4 assists */

	
			/* Team and Player Trends: */

--Q1: Team Contribution Analysis: Which team had the highest first picks and first round picks since 1996?

Select top 5 
	Case when team_abbreviation = 'CLE' then 'Cleveland Cavaliers'
		  when team_abbreviation = 'MIN' then 'Minnesota Timberwolves'
		  when team_abbreviation = 'CHI' then 'Chicago Bulls'
		  when team_abbreviation = 'ORL' then 'Orlando Magic'
		  when team_abbreviation = 'PHI' then 'Philadelphia 76ers'
		  Else team_abbreviation END as TeamName
	,sum(draft_number) as 'FirstPicks'
From Nba_Players_Data
Where draft_number = 1 and (CAST(SUBSTRING(season, 1, 4) AS int)-draft_year) = 0
Group by team_abbreviation
Order by 2 desc

	/* Cleveland Cavaliers had the highest first picks since 1996 (3) */

Select top 5 
	Case when team_abbreviation = 'CHI' then 'Chicago Bulls'
		 when team_abbreviation = 'BOS' then 'Boston Celtics'
		 when team_abbreviation = 'ATL' then 'Atlanta Hawks'
		 when team_abbreviation = 'GSW' then 'Golden State Warriors'
		 when team_abbreviation = 'MEM' then 'Memphis Grizzles'
		 Else team_abbreviation END as TeamName
	,sum(draft_round) as 'FirstPicks'
From Nba_Players_Data
Where draft_round = 1 and (CAST(SUBSTRING(season, 1, 4) AS int)-draft_year) = 0
Group by team_abbreviation
Order by 2 desc

	/* Chicago Bulls had the highest first round picks since 1996 (31) */

--Q2: Most Consistent Performers: Which players have averaged high points since their rookie season?

Select Distinct Top 10  player_name
	,age
	,pts
From Nba_Players_Data
Where pts > 10 and (CAST(SUBSTRING(season, 1, 4) AS int)-draft_year) = 0
Group by player_name, pts, age
Order by 3 desc

Select Distinct Top 10  player_name
	,age
	,pts
From Nba_Players_Data
Where pts > 10 and (CAST(SUBSTRING(season, 1, 4) AS int)-draft_year) = 15
Group by player_name, pts, age
Order by 3 desc

	/* After 15 years the rookie year these players have averaged consistent points: 
		Lebron James averaged 21 pts in rookie year and averaged 27 pts in 15th year
		Kevin Durant averaged 20 pts in rookie year and averaged 29 pts in 15th year */ 

			/* Demographics and Player Attributes: */

--Q1: Height & Performance: Is there a correlation between player height and their average rebounds or blocks per game?

Select Format(Avg(AverageReb), '#.#') as 'Average Rebound Over 210'
From (
Select player_height
	,Avg(reb) as 'AverageReb'
From Nba_Players_Data
Where player_height > 210 and reb > 5
Group by player_height) a


Select Format(Avg(AverageReb), '#.#') as 'Average Rebound Under 200'
From (
Select player_height
	,Avg(reb) as 'AverageReb'
From Nba_Players_Data
Where player_height < 200 and reb > 1
Group by player_height) a

	/* Players who over 210cm averages 7.6 rebounds (Players who averaged at least 5 rebounds per game) 
		While players who under 200cm averages 2.4 rebounds (Players who averaged at least 1 rebound per game) */

--Q2: Place of Birth & Performance: How do international players (born outside the U.S.) compare to U.S.-born players in terms of average points, rebounds, or assists?

Select country
	,avg(pts) as 'AvgPts'
	,avg(reb) as 'AvgReb'
	,avg(ast) as 'AvgAst'
From Nba_Players_Data
Where pts > 1 and reb > 1 and ast > 1
Group by country
Order by 4 desc

	/* International players especially European and African players averages higher points than U.S players
		Some african country players and U.S players averages high rebounds per game
		European players averages much higher assists per game than any other players (It includes the players who at least averaged 1 pts, reb, ast)*/

			/* Records and Highlights: */

--Q1: Single Season Records: Which player holds the record for the highest average points, rebounds, or assists in a single season?

Select top 5 player_name
	,max(pts) as 'AvgPts'
	,season
From Nba_Players_Data
Group by player_name, season
Order by 2 desc

Select top 5 player_name
	,max(reb) as 'AvgReb'
	,season
From Nba_Players_Data
Group by player_name, season
Order by 2 desc

Select top 5 player_name
	,max(ast) as 'AvgAst'
	,season
From Nba_Players_Data
Group by player_name, season
Order by 2 desc

	/* James Harden(2018-19) averaged 36.1 pts per game
		Danny Fortson (2000-01) averaged 16.3 rebs per game
		Rajon Rondo (2011-12, 2015-16) averaged 11.7 asts per game in both seasons */

--Q2: Triple-Double Leaders: Which players averaged triple-doubles (double digits in points, rebounds, and assists) in season?

Select player_name
	,count(*) as 'TripleDoubles'
	,season
From Nba_Players_Data
Where pts >= 10 and reb >=10 and ast >= 10
Group by player_name, season
Order by TripleDoubles desc
	
	/* Only Russell Westbrook averaged triple double in a season. He averaged it four times in his career. */
	
--Q3: Player Growth Over Career: How do a player's points, rebounds, and assists per game evolve from their rookie season to their final season?

Select player_name
	,Format(pts, '#.#') as 'AvgPts'
	,Format(reb, '#.#') as 'AvgReb'
	,Format(ast, '#.#') as 'AvgAst'
	,season
From Nba_Players_Data
Where player_name = 'Kobe Bryant'
Order by season

	/* Kobe Bryant’s points-per-game increased from around 7 in his rookie year to over 32 in his peak years and gradually declined as he neared retirement.
		His rebound and assits per game has been always over 2 since his rookie year */


			/* Advanced Statistical Insights: */

--Q1: How Lebron James' career stats affected when he joined Miami Heat to build Big 3?

Select player_name
	,team_abbreviation
	,avg(pts) as 'AvgPts'
	,avg(reb) as 'AvgReb'
	,avg(ast) as 'AvgAst'
	,avg(net_rating) as 'AvgNetRating'
From Nba_Players_Data
Where player_name = 'Lebron James' and (CAST(SUBSTRING(season, 1, 4) AS int)-draft_year) < 7 
Group by player_name, team_abbreviation

	/* The his first seven years in Cleveland, he averaged 27.8 pts 7 rebs 7 asts per game with 5.3 net rating (the offensive rating minus the defensive rating) */

Select player_name
	,team_abbreviation
	,avg(pts) as 'AvgPts'
	,avg(reb) as 'AvgReb'
	,avg(ast) as 'AvgAst'
	,avg(net_rating) as 'AvgNetRating'
From Nba_Players_Data
Where player_name = 'Lebron James' and team_abbreviation = 'MIA'
Group by player_name, team_abbreviation

	/* During the three years in Miami, he averaged 26.9 pts 7.6 rebs 6.7 asts per game with a 10.8 net rating (the offensive rating minus the defensive rating) 
		It shows that his stats did not change much however his net rating doubled meaning he became more efficient and effective on the floor */

--Q2: Which undrafted players have had the best performance based on their points, rebounds, and assists?

Select player_name
	,avg(pts) as 'AvgPts'
	,avg(reb) as 'AvgReb'
	,avg(ast) as 'AvgAst'
	,season
From Nba_Players_Data
Where draft_year is null and pts > 0 and reb > 0 and ast > 0
Group by player_name, season
Order by 2 desc

	/* Elijah Bryant who is undrafted had the highest point-per-game during his career. 
		While by season, Christian Wood and Fred VanVleet had the best performance season than all undrafted players. */

Select player_name
	,avg(pts) as 'AvgPts'
	,avg(reb) as 'AvgReb'
	,avg(ast) as 'AvgAst'
	,sum(gp) as 'TotalGames'
From Nba_Players_Data
Where draft_year is null 
Group by player_name
Order by 5 desc
	 
	 /* Ben Wallace had the most longest undrafted career in the league, averaging 5.4 pts 9 rebs 1.2 asts in 1088 games */
