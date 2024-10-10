/* Used database "ig_clone" to solve below queries */

/* 1Q. How many times does the average user post. */

SELECT * FROM PHOTOS;

WITH COUNT_IDS_CTE AS
(SELECT USER_ID, COUNT(*) COUNT_OF_IDS FROM PHOTOS GROUP BY 1 ORDER BY COUNT_OF_IDS DESC)

SELECT ROUND(AVG(COUNT_OF_IDS),2) AVG_USER_POST FROM COUNT_IDS_CTE;


/* 2Q. Find the top 5 most used hashtags. */

SELECT * FROM TAGS;
SELECT * FROM PHOTO_TAGS;

WITH TAG_IDS_CTE AS
(SELECT TAG_ID, COUNT(*) COUNT_TAG_IDS FROM PHOTO_TAGS GROUP BY 1 ORDER BY COUNT_TAG_IDS DESC LIMIT 5)

SELECT TAG_NAME FROM TAGS T
INNER JOIN TAG_IDS_CTE TIC
ON T.ID = TIC.TAG_ID;


/* 3Q. Find users who have liked every single photo on the site. */

SELECT * FROM USERS;
SELECT * FROM LIKES;

CREATE VIEW USERS_LIKES_PHOTO_VIEW AS
SELECT DISTINCT U.ID, USERNAME FROM USERS U 
LEFT JOIN LIKES L
ON U.ID = L.USER_ID; 

SELECT * FROM USERS_LIKES_PHOTO_VIEW;


/* 4Q. Retrieve a list of users along with their usernames and the rank of their account creation, 
       ordered by the creation date in ascending order. */

SELECT * FROM USERS;

SELECT USERNAME, RANK() OVER(ORDER BY CREATED_AT) RANK_ACC_CREATION FROM USERS;


/* 5Q. List the comments made on photos with their comment texts, photo URLs, 
       and usernames of users who posted the comments. Include the comment count for each photo. */

SELECT * FROM USERS;
SELECT * FROM PHOTOS;
SELECT * FROM COMMENTS;

WITH COMMENT_USER_CTE AS
(SELECT COMMENT_TEXT, USER_ID, PHOTO_ID FROM COMMENTS)

SELECT CU.COMMENT_TEXT, P.IMAGE_URL, USERNAME, COUNT(CU.COMMENT_TEXT) OVER (PARTITION BY U.USERNAME) AS COMMENT_COUNT 
FROM USERS U 
INNER JOIN COMMENT_USER_CTE CU
ON U.ID = CU.USER_ID
INNER JOIN PHOTOS P
ON P.USER_ID = U.ID;


/* 6Q. For each tag, show the tag name and the number of photos associated with that tag. 
	   Rank the tags by the number of photos in descending order. */

SELECT * FROM TAGS;
SELECT * FROM PHOTO_TAGS;

SELECT TAG_NAME, COUNT(PT.PHOTO_ID) AS NUM_OF_PHOTOS, 
DENSE_RANK() OVER(ORDER BY COUNT(PT.PHOTO_ID) DESC) RANK_OF_TAGS
FROM TAGS T 
INNER JOIN PHOTO_TAGS PT
ON T.ID = PT.TAG_ID
GROUP BY T.ID
ORDER BY NUM_OF_PHOTOS DESC;


/*7Q. List the usernames of users who have posted photos along with the count of photos they have posted. 
      Rank them by the number of photos in descending order. */

SELECT * FROM USERS;
SELECT * FROM PHOTOS;

SELECT USERNAME, COUNT(P.ID) AS COUNT_OF_PHOTOS, 
DENSE_RANK() OVER(ORDER BY COUNT(P.ID) DESC) RANK_OF_PHOTOS
FROM USERS U
INNER JOIN PHOTOS P
ON U.ID = P.USER_ID
GROUP BY U.ID
ORDER BY COUNT_OF_PHOTOS DESC;


/* 8Q. Display the username of each user along with the creation date of their first posted photo and 
       the creation date of their next posted photo. */
       
SELECT * FROM USERS;
SELECT * FROM PHOTOS;

SELECT USERNAME, P.CREATED_AT, 
LAG(P.CREATED_AT) OVER (ORDER BY P.CREATED_AT) FIRST_POST_CREATED_DATE,
LEAD(P.CREATED_AT) OVER (ORDER BY P.CREATED_AT) NEXT_POST_CREATED_DATE FROM USERS U
INNER JOIN PHOTOS P
ON U.ID = P.USER_ID;


/* 9Q. For each comment, show the comment text, the username of the commenter, and 
       the comment text of the previous comment made on the same photo. */

SELECT * FROM USERS;
SELECT * FROM COMMENTS;

SELECT USERNAME, COMMENT_TEXT, LAG(COMMENT_TEXT) OVER(ORDER BY PHOTO_ID) AS PREVIOUS_COMMENT
FROM COMMENTS C
INNER JOIN USERS U
ON U.ID = C.USER_ID;


/* 10Q. Show the username of each user along with the number of photos they have posted and 
        the number of photos posted by the user before them and after them, based on the creation date. */

SELECT * FROM USERS;
SELECT * FROM PHOTOS;

WITH USER_PHOTO_COUNT AS
(
    SELECT U.USERNAME, COUNT(P.USER_ID) AS NUM_OF_PHOTOS, MIN(U.CREATED_AT) AS DATE_OF_FIRST_PHOTO
    FROM USERS U
    LEFT JOIN PHOTOS P 
    ON U.ID = P.USER_ID
    GROUP BY U.USERNAME
)

SELECT 
    USERNAME, NUM_OF_PHOTOS,
    LAG(NUM_OF_PHOTOS, 1) OVER (ORDER BY DATE_OF_FIRST_PHOTO) AS PHOTOS_POSTED_BEFORE,
    LEAD(NUM_OF_PHOTOS, 1) OVER (ORDER BY DATE_OF_FIRST_PHOTO) AS PHOTOS_POSTED_AFTER
FROM USER_PHOTO_COUNT
ORDER BY DATE_OF_FIRST_PHOTO;