SET
	@post_to_restore = 679884;

/* 
 COPIAR wp_post_meta DESDE UNA DB A OTRA
 */
INSERT
	eventu_wp_prod_localhost.wp_postmeta
SELECT
	*
FROM
	eventu_wp_test_local.wp_postmeta TPM
WHERE
	TPM.post_id = @post_to_restore;

/* 
 COPIAR wp_post DESDE UNA DB A OTRA
 */
INSERT
	eventu_wp_prod_localhost.wp_posts
SELECT
	*
FROM
	eventu_wp_test_local.wp_posts TP
WHERE
	TP.ID = @post_to_restore;

/* 
 COPIA LOS wp_post_meta DE TICKETS DE EVENTO RECUPERADO INICALMENTE
 */
INSERT
	eventu_wp_prod_localhost.wp_postmeta
SELECT
	TPM.*
FROM
	eventu_wp_test_local.wp_postmeta TPM
	INNER JOIN (
		SELECT
			TP.*
		FROM
			eventu_wp_test_local.wp_posts TP
			LEFT JOIN eventu_wp_test_local.wp_postmeta TPM ON TP.ID = TPM.post_id
		WHERE
			(TPM.meta_value = @post_to_restore)
			AND TPM.meta_key = '_event_name'
	) PR ON TPM.post_id = PR.ID;

/* 
 COPIA LOS wp_post DE TICKETS DEL EVENTO RECUPERADO INICALMENTE
 */
INSERT
	eventu_wp_prod_localhost.wp_postmeta
SELECT
	TP.*
FROM
	eventu_wp_test_local.wp_posts TP
	LEFT JOIN eventu_wp_test_local.wp_postmeta TPM ON TP.ID = TPM.post_id
WHERE
	(TPM.meta_value = @post_to_restore)
	AND TPM.meta_key = '_event_name'