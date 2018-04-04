SELECT p.name, p.id
     , COALESCE(g.goalsum,0) AS goals
     , COALESCE(a.assistsum,0) AS assists
	 , COALESCE(g.goalsum,0) + COALESCE(a.assistsum,0) AS Points
	 , COALESCE(s.shotsum,0) AS shots
	 , COALESCE(h.hittersum,0) AS hits
	 , COALESCE(hd.hittedsum,0) AS hitted
FROM   player p
LEFT JOIN (
   SELECT player_id, count(*) AS goalsum
   FROM   goal
   GROUP  BY player_id
   ) g ON g.player_id = p.id
LEFT JOIN (
   SELECT player_id, count(*) AS assistsum
   FROM   assist
   GROUP  BY player_id
   ) a ON a.player_id = p.id
LEFT JOIN (
	SELECT player_id, count(*) AS shotsum
	FROM shot
	GROUP BY player_id
	) s ON s.player_id = p.id
LEFT JOIN (
	SELECT hitter_id, count(*) AS hittersum
	FROM hit
	GROUP BY hitter_id
	) h ON h.hitter_id = p.id
LEFT JOIN (
	SELECT hitted_id, count(*) AS hittedsum
	FROM hit
	GROUP BY hitted_id
	) hd ON hd.hitted_id = p.id
ORDER  BY Points DESC , goals DESC;