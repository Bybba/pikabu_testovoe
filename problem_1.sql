WITH
    helper AS (
        SELECT 
            DISTINCT t1.uid AS user_id, 
            t1.dt AS date, 
            (
                CASE WHEN t2.uid != 0 THEN 1 ELSE 0 END + 
                CASE WHEN t3.uid != 0 THEN 1 ELSE 0 END + 
                CASE WHEN t4.uid != 0 THEN 1 ELSE 0 END
            ) AS joined_next_dates
        FROM 
            test_pikabu AS t1
        LEFT JOIN 
            test_pikabu AS t2 
            ON t1.uid = t2.uid AND t2.dt = t1.dt + INTERVAL 1 DAY
        LEFT JOIN 
            test_pikabu AS t3 
            ON t1.uid = t3.uid AND t3.dt = t1.dt + INTERVAL 2 DAY
        LEFT JOIN 
            test_pikabu AS t4 
            ON t1.uid = t4.uid AND t4.dt = t1.dt + INTERVAL 3 DAY
    ),
    helper2 AS (
        SELECT 
            date,
            COUNT(CASE WHEN joined_next_dates >= 2 THEN 1 ELSE NULL END) AS days2,
            COUNT(CASE WHEN joined_next_dates >= 3 THEN 1 ELSE NULL END) AS days3
        FROM helper
        GROUP BY date
    )

SELECT
    main.dt AS dt,
    uniqExact(main.uid) AS num_of_uniq_users,
    SUM(uniqExact(main.uid)) OVER (
        ORDER BY main.dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_num_of_uniq_users,
    helper2.days2 AS num_of_uniq_users_who_for_the_next_3_days_visited_at_least_2_days,
    helper2.days3 AS num_of_uniq_users_who_for_the_next_3_days_visited_all_3_days
FROM
    (SELECT DISTINCT dt, uid FROM test_pikabu) AS main
LEFT JOIN
    helper2
    ON main.dt = helper2.date
GROUP BY
    main.dt, helper2.days2, helper2.days3
ORDER BY
    main.dt ASC;
