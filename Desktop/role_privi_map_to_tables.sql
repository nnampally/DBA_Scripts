select distinct a.oid as user_role_id
, a.rolname as user_role_name
--, b.roleid as other_role_id
, c.rolname as member_of
,  array_to_string(array_agg(distinct d.privilege_type),',') as privilege
,d.table_schema||'.'||d.table_name as tablename
from pg_roles a
inner join pg_auth_members b on a.oid=b.member
inner join pg_roles c on b.roleid=c.oid 
left join information_schema.role_table_grants d on d.grantee = c.rolname
where a.rolname not in ('pg_monitor','rds_superuser','rds_superuser')
group by 1,2,3,5
