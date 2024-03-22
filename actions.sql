START TRANSACTION;

SET
    @fecha_inicial = '2023-10-01';

/**
 *
 * BORRAMOS TODOS LOS TICKERA CHECKINS DE LA BASE DE DATOS
 *
 **/
DELETE P,
PM
FROM
    wp_posts AS P
    INNER JOIN wp_postmeta AS PM ON P.ID = PM.post_id
WHERE
    P.post_type = 'tc_tickets_instances'
    AND PM.meta_key = 'tc_checkins';

/**********************************
 *
 *          ORPHAN DATA
 *˚
 **********************************/
DROP TABLE IF EXISTS wp_posts_orphan;

CREATE TABLE wp_posts_orphan LIKE wp_posts;

DROP TABLE IF EXISTS wp_postmeta_orphan;

CREATE TABLE wp_postmeta_orphan LIKE wp_postmeta;

DROP TABLE IF EXISTS wp_comments_orphan;

CREATE TABLE wp_comments_orphan LIKE wp_comments;

/* wp_postmeta -> wp_postmeta_orphan */
INSERT
    wp_postmeta_orphan
SELECT
    PM.*
FROM
    wp_postmeta PM
    LEFT JOIN wp_posts P ON PM.post_id = P.ID
WHERE
    P.ID IS NULL;

DELETE PM
FROM
    wp_postmeta PM
    LEFT JOIN wp_posts P ON PM.post_id = P.ID
WHERE
    P.ID IS NULL;

/** wp_comments -> wp_comments_orphan */
INSERT
    wp_comments_orphan
SELECT
    C.*
FROM
    wp_comments C
    LEFT JOIN wp_posts P ON C.comment_post_ID = P.ID
WHERE
    P.ID IS NULL;

--
DELETE C
FROM
    wp_comments C
    LEFT JOIN wp_posts P ON C.comment_post_ID = P.ID
WHERE
    P.ID IS NULL;

/** wp_posts.post_parent -> wp_posts_orphan */
INSERT
    wp_posts_orphan
SELECT
    P.*
FROM
    wp_posts AS P
    LEFT JOIN wp_posts AS PP ON P.post_parent = PP.ID
WHERE
    PP.ID IS NULL
    AND (
        P.post_parent <> 0
        AND P.post_parent IS NOT NULL
    );

DELETE P
FROM
    wp_posts AS P
    LEFT JOIN wp_posts AS PP ON P.post_parent = PP.ID
WHERE
    PP.ID IS NULL
    AND (
        P.post_parent <> 0
        AND P.post_parent IS NOT NULL
    );

/**********************************
 *
 *          HISTORIC DATA
 *˚
 **********************************/
DROP TABLE IF EXISTS wp_posts_history;

CREATE TABLE wp_posts_history LIKE wp_posts;

DROP TABLE IF EXISTS wp_postmeta_history;

CREATE TABLE wp_postmeta_history LIKE wp_postmeta;

DROP TABLE IF EXISTS wp_comments_history;

CREATE TABLE wp_comments_history LIKE wp_comments;

/** wp_postmeta -> wp_postmeta_history */
INSERT
    wp_postmeta_history
SELECT
    PM.*
FROM
    wp_postmeta PM
    LEFT JOIN wp_posts P ON PM.post_id = P.ID
WHERE
    P.post_date < @fecha_inicial
    AND (
        P.post_type = 'tc_tickets_instances'
        OR P.post_type = 'shop_order'
        OR P.post_type = 'product'
        OR P.post_type = 'revision'
        OR P.post_type = 'shop_order_refund'
        OR P.post_type = 'tc_events'
        OR P.post_type = 'pos_temp_register_or'
        OR P.post_type = 'tc_seat_charts'
        OR P.post_type = 'pos_temp_order'
        OR P.post_type = 'shop_coupon'
        OR P.post_type = 'pos_session'
        OR P.post_type = 'pos_receipt'
    );

DELETE PM
FROM
    wp_postmeta PM
    LEFT JOIN wp_posts P ON PM.post_id = P.ID
WHERE
    P.post_date < @fecha_inicial
    AND (
        P.post_type = 'tc_tickets_instances'
        OR P.post_type = 'shop_order'
        OR P.post_type = 'product'
        OR P.post_type = 'revision'
        OR P.post_type = 'shop_order_refund'
        OR P.post_type = 'tc_events'
        OR P.post_type = 'pos_temp_register_or'
        OR P.post_type = 'tc_seat_charts'
        OR P.post_type = 'pos_temp_order'
        OR P.post_type = 'shop_coupon'
        OR P.post_type = 'pos_session'
        OR P.post_type = 'pos_receipt'
    );

/** wp_comments -> wp_comments_history */
INSERT
    wp_comments_history
SELECT
    C.*
FROM
    wp_comments C
    LEFT JOIN wp_posts P ON C.comment_post_ID = P.ID
WHERE
    P.post_date < @fecha_inicial;

DELETE C
FROM
    wp_comments C
    LEFT JOIN wp_posts P ON C.comment_post_ID = P.ID
WHERE
    P.post_date < @fecha_inicial;

/** wp_posts -> wp_posts_history */
INSERT
    wp_posts_history
SELECT
    P.*
FROM
    wp_posts P
WHERE
    P.post_date < @fecha_inicial
    AND (
        P.post_type = 'tc_tickets_instances'
        OR P.post_type = 'shop_order'
        OR P.post_type = 'product'
        OR P.post_type = 'revision'
        OR P.post_type = 'shop_order_refund'
        OR P.post_type = 'tc_events'
        OR P.post_type = 'pos_temp_register_or'
        OR P.post_type = 'tc_seat_charts'
        OR P.post_type = 'pos_temp_order'
        OR P.post_type = 'shop_coupon'
        OR P.post_type = 'pos_session'
        OR P.post_type = 'pos_receipt'
    );

DELETE P
FROM
    wp_posts P
    LEFT JOIN wp_postmeta PM ON P.ID = PM.post_id
WHERE
    P.post_date < @fecha_inicial
    AND (
        P.post_type = 'tc_tickets_instances'
        OR P.post_type = 'shop_order'
        OR P.post_type = 'product'
        OR P.post_type = 'revision'
        OR P.post_type = 'shop_order_refund'
        OR P.post_type = 'tc_events'
        OR P.post_type = 'pos_temp_register_or'
        OR P.post_type = 'tc_seat_charts'
        OR P.post_type = 'pos_temp_order'
        OR P.post_type = 'shop_coupon'
        OR P.post_type = 'pos_session'
        OR P.post_type = 'pos_receipt'
    );

/**********************************
 *
 *   DELETE ORPHAN WITHOUT SAVING
 *
 **********************************/
DELETE TTO
/* TABLE TO OPTIMIZE  */
FROM
    wp_wc_product_meta_lookup AS TTO
    LEFT JOIN wp_posts AS P ON TTO.product_id = P.ID
WHERE
    P.ID IS NULL;

DELETE OI,
IM
FROM
    wp_woocommerce_order_items AS OI
    LEFT JOIN wp_woocommerce_order_itemmeta AS IM ON OI.order_item_id = IM.order_item_id
    LEFT JOIN wp_posts AS PM ON OI.order_id = PM.ID
WHERE
    PM.ID IS NULL;

DELETE UM
FROM
    wp_usermeta UM
    LEFT JOIN wp_users U ON UM.user_id = U.ID
WHERE
    U.ID IS NULL;

/**********************************
 *
 *          TABLE DEFRAG
 *˚
 **********************************/
ALTER TABLE
    wp_posts ENGINE = INNODB;

ALTER TABLE
    wp_postmeta ENGINE = INNODB;

ALTER TABLE
    wp_comments ENGINE = INNODB;

COMMIT;