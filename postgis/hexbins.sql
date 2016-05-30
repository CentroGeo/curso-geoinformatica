ALTER TABLE hexbins ADD COLUMN escuelas INTEGER;

UPDATE hexbins h
SET escuelas = point_count
FROM ( SELECT a.id, count(*) AS point_count
       FROM hexbins a JOIN escuelas_utm b
       ON (ST_Contains(a.geom,b.geom))
       GROUP BY a.id
    ) AS c
WHERE h.id = c.id
