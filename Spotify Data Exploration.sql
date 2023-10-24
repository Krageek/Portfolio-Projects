

-- StreamingHistory Sheet which is entire streaming history for 1 year

Select *
From StreamingHistory;

-- Renaming columns in StreamingHistory
EXEC sp_rename 'StreamingHistory.Column1#endTime', 'endTime', 'COLUMN';
EXEC sp_rename 'StreamingHistory.Column1#artistName', 'Artist', 'COLUMN';
EXEC sp_rename 'StreamingHistory.Column1#trackName', 'Track', 'COLUMN';
EXEC sp_rename 'StreamingHistory.Column1#msPlayed', 'msPlayed', 'COLUMN';

-- Looking up data types of all the columns in StreamingHistory
Select Column_Name, Data_type
From INFORMATION_SCHEMA.COLUMNS
Where TABLE_NAME = 'StreamingHistory';

-- Modifying data type of a column to datetime
ALTER TABLE StreamingHistory
ALTER COLUMN endTime DateTime;

-- Number of Minutes spent listening to each Artist
Select Artist, SUM(msPlayed/(1000 * 60)) as MinutesPlayed
From StreamingHistory
Group By Artist
Order By SUM(msPlayed) DESC;

-- Most played songs for the whole year
Select Artist, Track, SUM(msPlayed/(1000 * 60)) as MinutesPlayed, COUNT(Track) as NumberofPlays
From StreamingHistory
Group By Artist, Track
Order By COUNT(Track) DESC;


-- Number of minutes listened this month
Select cast(SUM(msPlayed/(1000 * 60)) as int) as MinutesListened
--Select SUM(msPlayed) as MinutesListened
From StreamingHistory
Where endTime > '2023-09-30 23:59';

-- New songs that I have heard this month (97)

Select COUNT(DISTINCT(Track)) as NewSongs
From StreamingHistory
Where Track NOT IN (Select DISTINCT(Track)
					From StreamingHistory
					Where endTime <= '2023-09-30 23:59');

Select *
From StreamingHistory
Where endTime < '2023-10-01'

Select *
From StreamingHistory
Where Track Like '?';

-- Deleting rows with Artist or Track being null (0)
DELETE
From StreamingHistory
Where Artist is null OR Track is null;

-- Total number of songs heard in the last year
Select COUNT(DISTINCT(Track)) as TotalSongs
From StreamingHistory

-- Number of new artists listened to this month
Select COUNT(DISTINCT(Artist)) as NewArtists
From StreamingHistory
Where Artist NOT IN (Select DISTINCT(Artist)
					From StreamingHistory
					Where endTime < '2023-10-01');

Select DISTINCT(Artist) as NewArtists
From StreamingHistory
Where Artist NOT IN (Select DISTINCT(Artist)
					From StreamingHistory
					Where endTime < '2023-10-01');

-- Number of hours listened in the last year
--Select SUM(((msPlayed/1000)/60)/60)
Select cast(SUM(msPlayed/(1000 * 60)) as int) as MinutesListenedYearly
From StreamingHistory

-- Number of hours listened in each month
Select FORMAT(endTime, 'yyyy-MM') as MonthDate, SUM(msPlayed/(1000 * 60 * 60)) as HoursPlayed
From StreamingHistory
Group By FORMAT(endTime, 'yyyy-MM')
Order By FORMAT(endTime, 'yyyy-MM');

-- Hours of the day during which music was heard the most
Select DATEPART(HOUR, endTime) as HourofDay, SUM(msPlayed/(1000 * 60 * 60)) as HoursPlayed
From StreamingHistory
Group By DATEPART(HOUR, endTime)
--Order By SUM(msPlayed/(1000 * 60 * 60)) DESC;
Order By DATEPART(HOUR, endTime)

-- Days of the week during which music was heard the most (by hours)
Select DATENAME(WEEKDAY, endTime) as DayoftheWeek, SUM(msPlayed/(1000 * 60 * 60)) as HoursPlayed
From StreamingHistory
Group By DATENAME(WEEKDAY, endTime)
Order By SUM(msPlayed/(1000 * 60 * 60)) DESC;

-- Number of Distinct Songs in the whole year
Select COUNT(DISTINCT CONCAT(Track, ',', Artist)) as NumberofDistinctSongs
From StreamingHistory;





-- Playlists in Spotify Data
Select * 
From Playlists;

DELETE
From Playlists
Where PlaylistName LIKE 'Wife'

-- Dropping columns with no importance
ALTER TABLE Playlists
DROP COLUMN Name, Value#lastModifiedDate, Value#items#addedDate;

-- Renaming columns
EXEC sp_rename 'Playlists.Value#name', 'PlaylistName', 'COLUMN';
EXEC sp_rename 'Playlists.Value#items#track#trackName', 'Track', 'COLUMN';
EXEC sp_rename 'Playlists.Value#items#track#artistName', 'Artist', 'COLUMN';
EXEC sp_rename 'Playlists.Value#items#track#albumName', 'Album', 'COLUMN';

-- Removing songs which recur in the playlist 
WITH RemoveDuplicates as (
Select *
, ROW_NUMBER() OVER (PARTITION BY Artist, Track Order By Artist) AS Row_Rep
From Playlists)
DELETE
From RemoveDuplicates
Where Row_Rep > 1

-- Artists ranked by number of songs in my playlist (called 'Downloaded Playlist')
Select Artist, COUNT(Track) as Songs
From Playlists
Where PlayListName LIKE 'Downloaded Playlist'
Group By Artist
Order By COUNT(Track) DESC;


-- LikedSongs table contains another playlist
-- Cleaning up playlist 'LikedSongs' data 
Select *
From LikedSongs;

-- Renaming columns in LikedSongs
EXEC sp_rename 'LikedSongs.Value#artist', 'Artist', 'COLUMN';
EXEC sp_rename 'LikedSongs.Value#album', 'Album', 'COLUMN';
EXEC sp_rename 'LikedSongs.Value#track', 'Track', 'COLUMN';

-- Deleting rows where there are null values
DELETE
From LikedSongs
Where Artist is null OR Album is null OR Track is null; 

-- Ranking Artists by Number of Songs in LikedSongs playlist
Select Artist, COUNT(Track) as NumberofSongs
From LikedSongs
Group By Artist
Order by COUNT(Track) DESC;

-- Dropping irrelvant column
ALTER TABLE LikedSongs
DROP COLUMN Name;

-- Ranking Artists by Number of Songs
--With MyMusic as (
--	SELECT Artist, Track
--	From Playlists
--	Where PlaylistName LIKE 'Downloaded Playlist'
--	UNION
--	SELECT Artist, Track
--	From LikedSongs
--)
--Select Artist, COUNT(Track) as Songs
--From MyMusic
--Group By Artist
--Order By COUNT(Track) DESC;

-- Using View to rank artists by # of songs in my playlists (2 playlists together which are separate in two tables)
Create View MyMusicView AS
SELECT Artist, Track
From Playlists
Where PlaylistName LIKE 'Downloaded Playlist'
UNION
SELECT Artist, Track
From LikedSongs;

-- Artists ranked by Number of Songs in my playlists
Select Artist, COUNT(Track) as Songs
From MyMusicView
Group By Artist
Order By COUNT(Track) DESC;

--Select Artist, Track, COUNT(*) as Duplicates
--From Playlists
--Where PlaylistName LIKE 'Downloaded Playlist'
--Group By Artist, Track
--HAVING COUNT(*) > 1;

-- Number of Songs and Number of Artists in my playlist
Select COUNT(DISTINCT CONCAT(Track, ',', Artist)) as NumberofDistinctSongs, COUNT(DISTINCT(Artist)) as NumberofArtists
From MyMusicView;

--Select cast(SUM(msPlayed/(1000 * 60)) as int) as MinutesStreamedYearly
--From StreamingHistory;





