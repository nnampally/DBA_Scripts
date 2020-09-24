SELECT
    CONCAT("`",gcl.Db,"`") AS 'Database(s) Affected',
    CONCAT("`",gcl.Table_name,"`") AS 'Table(s) Affected',
    gcl.User AS 'User-Account(s) Affected',
    IF(gcl.Host='%','ALL',gcl.Host) AS 'Remote-IP(s) Affected',
    CONCAT("GRANT ",UPPER(gcl.Column_priv)," (",GROUP_CONCAT(gcl.Column_name),") ",
                 "ON `",gcl.Db,"`.`",gcl.Table_name,"` ",
                 "TO '",gcl.User,"'@'",gcl.Host,"';") AS 'GRANT Statement (Reconstructed)'
FROM mysql.columns_priv gcl
GROUP BY CONCAT(gcl.Db,gcl.Table_name,gcl.User,gcl.Host)

UNION

SELECT
    CONCAT("`",gtb.Db,"`") AS 'Database(s) Affected',
    CONCAT("`",gtb.Table_name,"`") AS 'Table(s) Affected',
    gtb.User AS 'User-Account(s) Affected',
    IF(gtb.Host='%','ALL',gtb.Host) AS 'Remote-IP(s) Affected',
    CONCAT(
        "GRANT ",UPPER(gtb.Table_priv)," ",
        "ON `",gtb.Db,"`.`",gtb.Table_name,"` "
        "TO '",gtb.User,"'@'",gtb.Host,"';"
    ) AS 'GRANT Statement (Reconstructed)'
FROM mysql.tables_priv gtb
WHERE gtb.Table_priv!=''


UNION


SELECT
    CONCAT("`",gdb.Db,"`") AS 'Database(s) Affected',
    "ALL" AS 'Table(s) Affected',
    gdb.User AS 'User-Account(s) Affected',
    IF(gdb.Host='%','ALL',gdb.Host) AS 'Remote-IP(s) Affected',
    CONCAT(
        'GRANT ',
        CONCAT_WS(',',
            IF(gdb.Select_priv='Y','SELECT',NULL),
            IF(gdb.Insert_priv='Y','INSERT',NULL),
            IF(gdb.Update_priv='Y','UPDATE',NULL),
            IF(gdb.Delete_priv='Y','DELETE',NULL),
            IF(gdb.Create_priv='Y','CREATE',NULL),
            IF(gdb.Drop_priv='Y','DROP',NULL),
            IF(gdb.Grant_priv='Y','GRANT',NULL),
            IF(gdb.References_priv='Y','REFERENCES',NULL),
            IF(gdb.Index_priv='Y','INDEX',NULL),
            IF(gdb.Alter_priv='Y','ALTER',NULL),
            IF(gdb.Create_tmp_table_priv='Y','CREATE TEMPORARY TABLES',NULL),
            IF(gdb.Lock_tables_priv='Y','LOCK TABLES',NULL),
            IF(gdb.Create_view_priv='Y','CREATE VIEW',NULL),
            IF(gdb.Show_view_priv='Y','SHOW VIEW',NULL),
            IF(gdb.Create_routine_priv='Y','CREATE ROUTINE',NULL),
            IF(gdb.Alter_routine_priv='Y','ALTER ROUTINE',NULL),
            IF(gdb.Execute_priv='Y','EXECUTE',NULL),
            IF(gdb.Event_priv='Y','EVENT',NULL),
            IF(gdb.Trigger_priv='Y','TRIGGER',NULL)
        ),
        " ON `",gdb.Db,"`.* TO '",gdb.User,"'@'",gdb.Host,"';"
    ) AS 'GRANT Statement (Reconstructed)'
FROM mysql.db gdb
WHERE gdb.Db != ''


UNION

/* User-Specific Grants */
SELECT
    "ALL" AS 'Database(s) Affected',
    "ALL" AS 'Table(s) Affected',
    gus.User AS 'User-Account(s) Affected',
    IF(gus.Host='%','ALL',gus.Host) AS 'Remote-IP(s) Affected',
    CONCAT(
        "GRANT ",
        IF((gus.Select_priv='N')&(gus.Insert_priv='N')&(gus.Update_priv='N')&(gus.Delete_priv='N')&(gus.Create_priv='N')&(gus.Drop_priv='N')&(gus.Reload_priv='N')&(gus.Shutdown_priv='N')&(gus.Process_priv='N')&(gus.File_priv='N')&(gus.References_priv='N')&(gus.Index_priv='N')&(gus.Alter_priv='N')&(gus.Show_db_priv='N')&(gus.Super_priv='N')&(gus.Create_tmp_table_priv='N')&(gus.Lock_tables_priv='N')&(gus.Execute_priv='N')&(gus.Repl_slave_priv='N')&(gus.Repl_client_priv='N')&(gus.Create_view_priv='N')&(gus.Show_view_priv='N')&(gus.Create_routine_priv='N')&(gus.Alter_routine_priv='N')&(gus.Create_user_priv='N')&(gus.Event_priv='N')&(gus.Trigger_priv='N')&(gus.Create_tablespace_priv='N')&(gus.Grant_priv='N'),
            "USAGE",
            IF((gus.Select_priv='Y')&(gus.Insert_priv='Y')&(gus.Update_priv='Y')&(gus.Delete_priv='Y')&(gus.Create_priv='Y')&(gus.Drop_priv='Y')&(gus.Reload_priv='Y')&(gus.Shutdown_priv='Y')&(gus.Process_priv='Y')&(gus.File_priv='Y')&(gus.References_priv='Y')&(gus.Index_priv='Y')&(gus.Alter_priv='Y')&(gus.Show_db_priv='Y')&(gus.Super_priv='Y')&(gus.Create_tmp_table_priv='Y')&(gus.Lock_tables_priv='Y')&(gus.Execute_priv='Y')&(gus.Repl_slave_priv='Y')&(gus.Repl_client_priv='Y')&(gus.Create_view_priv='Y')&(gus.Show_view_priv='Y')&(gus.Create_routine_priv='Y')&(gus.Alter_routine_priv='Y')&(gus.Create_user_priv='Y')&(gus.Event_priv='Y')&(gus.Trigger_priv='Y')&(gus.Create_tablespace_priv='Y')&(gus.Grant_priv='Y'),
                "ALL PRIVILEGES",
                CONCAT_WS(',',
                    IF(gus.Select_priv='Y','SELECT',NULL),
                    IF(gus.Insert_priv='Y','INSERT',NULL),
                    IF(gus.Update_priv='Y','UPDATE',NULL),
                    IF(gus.Delete_priv='Y','DELETE',NULL),
                    IF(gus.Create_priv='Y','CREATE',NULL),
                    IF(gus.Drop_priv='Y','DROP',NULL),
                    IF(gus.Reload_priv='Y','RELOAD',NULL),
                    IF(gus.Shutdown_priv='Y','SHUTDOWN',NULL),
                    IF(gus.Process_priv='Y','PROCESS',NULL),
                    IF(gus.File_priv='Y','FILE',NULL),
                    IF(gus.References_priv='Y','REFERENCES',NULL),
                    IF(gus.Index_priv='Y','INDEX',NULL),
                    IF(gus.Alter_priv='Y','ALTER',NULL),
                    IF(gus.Show_db_priv='Y','SHOW DATABASES',NULL),
                    IF(gus.Super_priv='Y','SUPER',NULL),
                    IF(gus.Create_tmp_table_priv='Y','CREATE TEMPORARY TABLES',NULL),
                    IF(gus.Lock_tables_priv='Y','LOCK TABLES',NULL),
                    IF(gus.Execute_priv='Y','EXECUTE',NULL),
                    IF(gus.Repl_slave_priv='Y','REPLICATION SLAVE',NULL),
                    IF(gus.Repl_client_priv='Y','REPLICATION CLIENT',NULL),
                    IF(gus.Create_view_priv='Y','CREATE VIEW',NULL),
                    IF(gus.Show_view_priv='Y','SHOW VIEW',NULL),
                    IF(gus.Create_routine_priv='Y','CREATE ROUTINE',NULL),
                    IF(gus.Alter_routine_priv='Y','ALTER ROUTINE',NULL),
                    IF(gus.Create_user_priv='Y','CREATE USER',NULL),
                    IF(gus.Event_priv='Y','EVENT',NULL),
                    IF(gus.Trigger_priv='Y','TRIGGER',NULL),
                    IF(gus.Create_tablespace_priv='Y','CREATE TABLESPACE',NULL)
                )
            )
        ),
        " ON *.* TO '",gus.User,"'@'",gus.Host,"' REQUIRE ",
        CASE gus.ssl_type
            WHEN 'ANY' THEN
                "SSL "
            WHEN 'X509' THEN
                "X509 "
            WHEN 'SPECIFIED' THEN
                CONCAT_WS("AND ",
                    IF((LENGTH(gus.ssl_cipher)>0),CONCAT("CIPHER '",CONVERT(gus.ssl_cipher USING utf8),"' "),NULL),
                    IF((LENGTH(gus.x509_issuer)>0),CONCAT("ISSUER '",CONVERT(gus.ssl_cipher USING utf8),"' "),NULL),
                    IF((LENGTH(gus.x509_subject)>0),CONCAT("SUBJECT '",CONVERT(gus.ssl_cipher USING utf8),"' "),NULL)
                )
            ELSE "NONE "
        END,
        "WITH ",
        IF(gus.Grant_priv='Y',"GRANT OPTION ",""),
        "MAX_QUERIES_PER_HOUR ",gus.max_questions," ",
        "MAX_CONNECTIONS_PER_HOUR ",gus.max_connections," ",
        "MAX_UPDATES_PER_HOUR ",gus.max_updates," ",
        "MAX_USER_CONNECTIONS ",gus.max_user_connections,
        ";"
    ) AS 'GRANT Statement (Reconstructed)'
FROM mysql.user gus
WHERE gus.Password != '';

