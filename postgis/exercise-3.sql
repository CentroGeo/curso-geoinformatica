SELECT DISTINCT ON (e.nombrect) e.id, e.nombrect, e.geom, ST_Distance(e.geom, c.geom) 
FROM (SELECT * FROM escuelas_utm WHERE n_nivel LIKE '%PRIMARIA%' OR n_nivel LIKE '%SECUNDARIA%') AS e 
JOIN (SELECT * FROM calles_utm WHERE class_id IN (101, 102, 103, 106, 107, 108)) AS c
ON ST_DWithin(e.geom,c.geom,50)
ORDER BY e.nombrect, ST_Distance(e.geom, c.geom)
