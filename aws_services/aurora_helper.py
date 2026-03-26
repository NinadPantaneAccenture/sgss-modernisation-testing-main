import boto3
import logging
from .aws_config import TestConfig

logger = logging.getLogger(__name__)

class AuroraHelper:
    """Helper class for Aurora database operations using RDS Data API"""
    
    def __init__(self, database, port=5432):
        """
        Initialize Aurora RDS Data API client
        
        Args:
            database: Database name
            port: Database port (default 5432 for PostgreSQL)
        """
        self.database = database
        self.port = port
        self.column_cache = {}  # Cache for table column names
        
        # Initialize RDS Data API client
        if hasattr(TestConfig, 'AWS_ACCESS_KEY_ID') and TestConfig.AWS_ACCESS_KEY_ID:
            self.rds_client = boto3.client(
                'rds-data',
                region_name=TestConfig.AWS_REGION,
                aws_access_key_id=TestConfig.AWS_ACCESS_KEY_ID,
                aws_secret_access_key=TestConfig.AWS_SECRET_ACCESS_KEY
            )
        else:
            self.rds_client = boto3.client('rds-data', region_name=TestConfig.AWS_REGION)
        
        # Get Aurora cluster ARN and secret ARN from config
        self.resource_arn = getattr(TestConfig, 'AURORA_RESOURCE_ARN', None)
        self.secret_arn = TestConfig.AURORA_SECRET_NAME
    
    def get_column_names(self, table_name):
        """
        Get column names for a table from information_schema
        
        Args:
            table_name: Table name (can be schema.table format)
        
        Returns:
            list: List of column names in order
        """
        if table_name in self.column_cache:
            return self.column_cache[table_name]
        
        # Parse schema and table
        if '.' in table_name:
            schema, table = table_name.split('.')
        else:
            schema = 'public'
            table = table_name
        
        # Query information_schema to get columns in order
        query = f"""
            SELECT column_name FROM information_schema.columns 
            WHERE table_schema = '{schema}' AND table_name = '{table}'
            ORDER BY ordinal_position
        """
        
        try:
            response = self.rds_client.execute_statement(
                secretArn=self.secret_arn,
                resourceArn=self.resource_arn,
                database=self.database,
                sql=query
            )
            
            column_names = []
            if 'records' in response:
                for record in response['records']:
                    if record and 'stringValue' in record[0]:
                        column_names.append(record[0]['stringValue'])
            
            self.column_cache[table_name] = column_names
            #logger.info(f"Cached columns for {table_name}: {column_names}") #useful for figuring out aurora api responses
            return column_names
        except Exception as e:
            logger.error(f"Failed to get column names for {table_name}: {e}")
            return []
    
    def execute_query(self, query, params=None, table_name=None):
        """
        Execute a SELECT query using RDS Data API
        
        Args:
            query: SQL query string
            params: Query parameters (optional)
            table_name: Table name for getting column metadata (optional but recommended)
        
        Returns:
            list: List of result rows as dictionaries
        """
        try:
            response = self.rds_client.execute_statement(
                secretArn=self.secret_arn,
                resourceArn=self.resource_arn,
                database=self.database,
                sql=query
            )
            
            logger.info(f"DEBUG - Response keys: {response.keys()}")
            
            # Convert RDS Data API response to list of dicts
            records = []
            if 'records' in response and response['records']:
                # Get column names from table schema
                if table_name:
                    column_names = self.get_column_names(table_name)
                else:
                    # Try to extract from query - basic fallback
                    column_names = []
                
                #logger.info(f"DEBUG - Column names: {column_names}")
                
                for record in response['records']:
                    row_dict = {}
                    for i, value_dict in enumerate(record):
                        col_name = column_names[i] if i < len(column_names) else f'col_{i}'
                        
                        # Extract value from RDS Data API format
                        if 'stringValue' in value_dict:
                            row_dict[col_name] = value_dict['stringValue']
                        elif 'longValue' in value_dict:
                            row_dict[col_name] = value_dict['longValue']
                        elif 'doubleValue' in value_dict:
                            row_dict[col_name] = value_dict['doubleValue']
                        elif 'booleanValue' in value_dict:
                            row_dict[col_name] = value_dict['booleanValue']
                        elif 'isNull' in value_dict and value_dict['isNull']:
                            row_dict[col_name] = None
                    records.append(row_dict)
            
            logger.info(f"Query returned {len(records)} rows")
            return records
        except Exception as e:
            logger.error(f"Failed to execute query: {e}")
            raise
    
    def execute_update(self, query, params=None):
        """
        Execute an INSERT, UPDATE, or DELETE query using RDS Data API
        
        Args:
            query: SQL query string
            params: Query parameters (optional)
        
        Returns:
            int: Number of affected rows
        """
        try:
            response = self.rds_client.execute_statement(
                secretArn=self.secret_arn,
                resourceArn=self.resource_arn,
                database=self.database,
                sql=query
            )
            
            affected_rows = response.get('numberOfRecordsUpdated', 0)
            
            logger.info(f"Query affected {affected_rows} rows")
            return affected_rows
        except Exception as e:
            logger.error(f"Failed to execute update: {e}")
            raise
    
    def table_exists(self, table_name):
        """
        Check if a table exists in the database
        
        Args:
            table_name: Name of the table
        
        Returns:
            bool: True if table exists
        """
        query = """
            SELECT COUNT(*) as count
            FROM information_schema.tables
            WHERE table_schema = %s AND table_name = %s
        """
        results = self.execute_query(query, (self.database, table_name))
        return results[0]['count'] > 0
    
    def get_row_count(self, table_name, where_clause=None, params=None):
        """
        Get row count from a table
        
        Args:
            table_name: Name of the table
            where_clause: Optional WHERE clause (e.g., "status = %s")
            params: Parameters for WHERE clause
        
        Returns:
            int: Number of rows
        """
        query = f"SELECT COUNT(*) as count FROM {table_name}"
        if where_clause:
            query += f" WHERE {where_clause}"
        
        results = self.execute_query(query, params)
        return results[0]['count']
    
    def verify_records_exist(self, table_name, where_clause, params=None, expected_count=None):
        """
        Verify that records exist matching criteria
        
        Args:
            table_name: Name of the table
            where_clause: WHERE clause for filtering
            params: Parameters for WHERE clause
            expected_count: Optional expected number of records
        
        Returns:
            tuple: (success: bool, actual_count: int)
        """
        count = self.get_row_count(table_name, where_clause, params)
        
        if expected_count is not None:
            success = count == expected_count
            logger.info(f"Expected {expected_count} records, found {count}")
        else:
            success = count > 0
            logger.info(f"Found {count} records")
        
        return success, count
    
    def get_records(self, table_name, where_clause=None, params=None, limit=None):
        """
        Get records from a table
        
        Args:
            table_name: Name of the table
            where_clause: Optional WHERE clause
            params: Parameters for WHERE clause
            limit: Optional LIMIT clause
        
        Returns:
            list: List of records as dictionaries
        """
        query = f"SELECT * FROM {table_name}"
        if where_clause:
            query += f" WHERE {where_clause}"
        if limit:
            query += f" LIMIT {limit}"
        
        return self.execute_query(query, params, table_name=table_name)
    
    def get_record_count(self, table_name, where_clause=None, params=None):
        """
        Get the count of records in a table
        
        Args:
            table_name: Name of the table
            where_clause: Optional WHERE clause
            params: Parameters for WHERE clause
        
        Returns:
            int: Number of matching records
        """
        query = f"SELECT COUNT(*) as count FROM {table_name}"
        if where_clause:
            query += f" WHERE {where_clause}"
        
        results = self.execute_query(query, params, table_name=table_name)
        return results[0]['count'] if results else 0
    
        
    def delete_records(self, table_name, where_clause, params=None):
        """
        Delete records from a table
        
        Args:
            table_name: Name of the table
            where_clause: WHERE clause for filtering
            params: Parameters for WHERE clause
        
        Returns:
            int: Number of deleted rows
        """
        query = f"DELETE FROM {table_name} WHERE {where_clause}"
        return self.execute_update(query, params)
    
    def truncate_table(self, table_name):
        """
        Truncate a table (remove all rows)
        
        Args:
            table_name: Name of the table
        
        Returns:
            bool: True if successful
        """
        try:
            query = f"TRUNCATE TABLE {table_name}"
            self.execute_update(query)
            logger.info(f"Truncated table: {table_name}")
            return True
        except Exception as e:
            logger.error(f"Failed to truncate table: {e}")
            return False
    
    def verify_column_values(self, table_name, column_name, expected_values, where_clause=None, params=None):
        """
        Verify that a column contains expected values
        
        Args:
            table_name: Name of the table
            column_name: Column to check
            expected_values: List of expected values
            where_clause: Optional WHERE clause
            params: Parameters for WHERE clause
        
        Returns:
            tuple: (success: bool, actual_values: list)
        """
        query = f"SELECT {column_name} FROM {table_name}"
        if where_clause:
            query += f" WHERE {where_clause}"
        
        results = self.execute_query(query, params)
        actual_values = [row[column_name] for row in results]
        
        success = set(actual_values) == set(expected_values)
        
        if not success:
            logger.warning(f"Expected values: {expected_values}, Actual values: {actual_values}")
        
        return success, actual_values
    
    def get_table_schema(self, table_name):
        """
        Get the schema/structure of a table
        
        Args:
            table_name: Name of the table
        
        Returns:
            list: List of column definitions
        """
        query = """
            SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_KEY, COLUMN_DEFAULT
            FROM information_schema.columns
            WHERE table_schema = %s AND table_name = %s
            ORDER BY ORDINAL_POSITION
        """
        return self.execute_query(query, (self.database, table_name))