SELECT DISTINCT D.DATNAME AS DB_NAME,
	R.ROLNAME AS USERNAME,
	S.QUERY,
	S.CALLS
FROM DBADMIN.PG_STAT_STATEMENTS S,
	PG_ROLES R,
	PG_DATABASE D
WHERE S.USERID = R.OID
				AND S.DBID = D.OID
				AND D.DATNAME not in ('postgres',
																											'rdsadmin',
																											'template')
				AND QUERY like '%sec_user_organization%'
				AND QUERY NOT LIKE '%pg_stat_Statements%'
