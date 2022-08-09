import boto3
from datetime import timedelta
import time

def waiter_db_cluster(db_cluster_name, waitertype, Delay, MaxAttempts):
    start_time = time.time()
    try:
        for cycles in range(MaxAttempts, 1, -1):
            cluster_status_request = aws_conn.describe_db_clusters(
                DBClusterIdentifier=db_cluster_name,
            )
            if waitertype.lower() == 'delete':
                if not cluster_status_request['DBClusters'][0]['Status'] or cluster_status_request is None:
                    logger.info("Cluster cleanup completed.")
                    break
                else:
                    print("Delete cluster in progress...(" + str(timedelta(seconds=(time.time() - start_time))) + ")",
                          end='\r')
                    time.sleep(Delay)
            elif waitertype.lower() == 'create':
                if cluster_status_request['DBClusters'][0]['Status'] == 'available':
                    logger.info("Create/restore cluster completed and ready to connect:" + str(db_cluster_name))
                    break
                else:
                    print("Create/restore cluster in progress...(" + str(
                        timedelta(seconds=(time.time() - start_time))) + ")",
                          end='\r')
                    time.sleep(Delay)
            else:
                logger.error('waitertype supports only `delete` or `create` cluster')
    except Exception as err:
        if 'DBClusterNotFoundFault' in err.response['Error']['Code']:
            logger.info(err)
            logger.info('Cluster deleted or does not exist')
            pass
        else:
            logger.error("Waite error :" + str(err))
            exit(1)
            
            
 
