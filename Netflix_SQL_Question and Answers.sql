DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
( 
	show_id VARCHAR(100) PRIMARY KEY,
	typess VARCHAR(300),
	title VARCHAR(300),
	director VARCHAR(300),
	casts VARCHAR(1000),
	country VARCHAR(300),
	date_added DATE,
	release_year INT,
	rating VARCHAR(300),
	duration VARCHAR(300),
	listed_in VARCHAR(300),
	description VARCHAR(500)
)



-- 1. Count the number of Movies vs TV Shows
	SELECT typess, COUNT(*) FROM netflix
	GROUP BY typess
	ORDER BY COUNT(*) DESC

-- 2. Find the most common rating for movies and TV shows
	SELECT distinct(rating) FROM netflix
	
	WITH results as
	(
		SELECT typess, rating,
		ROW_NUMBER() OVER(PARTITION BY typess ORDER BY COUNT(rating) DESC) as row_num
		FROM netflix
		GROUP BY typess,rating
		ORDER BY typess
	)
	SELECT typess,rating FROM results
	WHERE row_num = 1

-- 3. List all movies released in a specific year (e.g., 2020)
	SELECT title, release_year FROM netflix
	WHERE typess = 'Movie' AND release_year = 2020

-- 4. Find the top 5 countries with the most content on Netflix
	WITH results as 
	(
	SELECT *,
	UNNEST(STRING_TO_ARRAY(country, ',')) as con
	FROM netflix
	) 
	
	SELECT con, COUNT(*)
	FROM results
	GROUP BY con
	ORDER BY COUNT(*) DESC
	LIMIT 5

-- 5. Identify the longest movie
	SELECT title, split_part(duration, ' ',1)::INT
	FROM netflix
	ORDER BY split_part(duration, ' ',1)::INT DESC
	LIMIT 1

-- 6. Find content added in the last 6 years
	SELECT *
	FROM netflix
	WHERE date_added >= CURRENT_DATE - INTERVAL '6 Years'

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
	SELECT *
	FROM netflix
	WHERE director LIKE  '%Rajiv Chilaka%'

-- 8. List all TV shows with more than 5 seasons
	SELECT title, SPLIT_PART(duration, ' ' , 1)::INT as season
	FROM netflix
	WHERE typess = 'TV Show' AND SPLIT_PART(duration, ' ' , 1)::INT > 5
	ORDER BY season DESC

-- 9. Count the number of content items in each genre
	SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre, COUNT(*) 
	FROM netflix
	GROUP BY 1
	ORDER BY 2 DESC

/*	10. Find each year and the  numbers of content release by India on netflix. 
	return top 5 year with highest content release !*/
	SELECT release_year ,COUNT(show_id) as av
	FROM netflix
	WHERE country LIKE '%India%'
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 5

-- 11. List all movies that are documentaries
	SELECT title, 
	FROM netflix
	WHERE typess = 'Movie' AND listed_in LIKE '%Documentaries%'

-- 12. Find all content without a director
	SELECT * FROM netflix
	WHERE director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
	SELECT * FROM netflix
	WHERE casts  LIKE '%Salman Khan%'
	AND
	release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
	SELECT 
		UNNEST(STRING_TO_ARRAY(casts, ',')), COUNT(typess)
	FROM netflix
	WHERE country LIKE '%India%'
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 10

/*	Question 15 Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
	the description field. Label content containing these keywords as 'Bad' and all other 
	content as 'Good'. Count how many items fall into each category. */
	WITH results as 
	(
		SELECT description, typess,
		CASE
		  	WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'BAD'
			  ELSE 'GOOD'
		END as Contents
		FROM netflix
	)
	SELECT typess, contents, COUNT(Contents)
	FROM results
	GROUP BY 1,2
	ORDER BY 1












