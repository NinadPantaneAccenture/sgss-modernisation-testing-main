
from behave import step
from behave.api.async_step import async_run_until_complete

from datetime import datetime
import boto3
import time
import logging


from aws_services.s3_helper import S3Helper
from aws_services.glue_helper import GlueHelper
from aws_services.aurora_helper import AuroraHelper
from aws_services.aws_config import TestConfig
from pages.common_page import Common

logger = logging.getLogger(__name__)


@step('the Aurora test table is cleaned')
def step_clean_aurora_table(context):
    """Clean up Aurora test table by triggering Glue job"""
    try:
        # Trigger Glue job to clean Aurora tables
        job_arguments = {
            "--aurora_secret_name": TestConfig.AURORA_SECRET_NAME,
            "--clean_mode": "true"
        }
        
        context.clean_job_run_id = context.glue_helper.start_job_run(
            TestConfig.GLUE_CLEAN_JOB_NAME,
            job_arguments
        )
        
        assert context.clean_job_run_id, "Failed to start Glue clean job"
        print(f"Started Glue clean job run: {context.clean_job_run_id}")
        
        # Wait for job to complete
        success, status, details = context.glue_helper.wait_for_job_completion(
            TestConfig.GLUE_CLEAN_JOB_NAME,
            context.clean_job_run_id,
            timeout=TestConfig.GLUE_JOB_TIMEOUT,
            poll_interval=TestConfig.GLUE_POLL_INTERVAL
        )
        
        # Verify job completed successfully
        assert success, f"Clean job failed with status: {status}"
        assert status == 'SUCCEEDED', f"Expected SUCCEEDED, got {status}"
        print(f"Aurora cleanup completed successfully")
        
    except Exception as e:
        print(f"Error during Aurora cleanup: {e}")
        raise


@step('the "{test_file}" file should be present in the file_name column of the "{table_name}" table')
def step_verify_file_in_table(context, test_file, table_name):
    """Verify the file is present in the file_name column of the last row of the specified table"""
    # Get the file name from the S3 key
    actual_file_name = context.s3_test_key.split('/')[-1]
    
    # Get the last record from the table (ordered by descending ID to get most recent)
    records = context.aurora_helper.get_records(
        table_name, 
        where_clause="1=1 ORDER BY created_date DESC", 
        limit=1
    )
    
    assert len(records) > 0, f"No records found in table '{table_name}'"
    
    last_record = records[0]
    logger.info(f"DEBUG - Last record columns: {list(last_record.keys())}")
    logger.info(f"DEBUG - Last record data: {last_record}")

    file_name_in_table = last_record.get('file_name')
    
    assert file_name_in_table is not None, \
        f"Column 'file_name' not found in record. Available columns: {list(last_record.keys())}"
    assert file_name_in_table == actual_file_name, \
        f"Expected file_name '{actual_file_name}' in last row, but got '{file_name_in_table}'"
    
    # Save the file_log_id to context for use in other steps
    context.file_log_id = last_record.get('file_log_id')
    assert context.file_log_id is not None, \
        f"Column 'file_log_id' not found in record. Available columns: {list(last_record.keys())}"
    
    logger.info(f"✅ File '{actual_file_name}' verified in last row of table '{table_name}' with file_log_id={context.file_log_id}")


@step('the "{test_file}" file should be absent in the file_name column of the "{table_name}" table')
def step_verify_file_in_table(context, test_file, table_name):
    """Verify the file is absent in the file_name column of the last row of the specified table"""
    # Get the file name from the S3 key
    actual_file_name = context.s3_test_key.split('/')[-1]
    
    # Get the last record from the table (ordered by descending ID to get most recent)
    records = context.aurora_helper.get_records(
        table_name, 
        where_clause="1=1 ORDER BY file_log_id DESC", 
        limit=1
    )
    
    assert len(records) > 0, f"No records found in table '{table_name}'"
    
    last_record = records[0]
    #logger.info(f"DEBUG - Last record columns: {list(last_record.keys())}")
    #logger.info(f"DEBUG - Last record data: {last_record}")

    file_name_in_table = last_record.get('file_name')
    
    assert file_name_in_table is not None, \
        f"Column 'file_name' not found in record. Available columns: {list(last_record.keys())}"
    assert file_name_in_table != actual_file_name, \
        f"Expected file_name '{actual_file_name}' to be absent in last row, but got '{file_name_in_table}'"
    
    # Save the file_log_id to context for use in other steps
    #context.file_log_id = last_record.get('file_log_id')
    #assert context.file_log_id is not None, \
     #   f"Column 'file_log_id' not found in record. Available columns: {list(last_record.keys())}"
    
    logger.info(f"✅ File '{actual_file_name}' absent in table '{table_name}'")


@step('the records in {table_name} table should match the source data in the {file_name} file')
@step('all records in the {file_name} file have been uploaded to the {table_name} table')
def step_verify_data_match(context, table_name, file_name):
    """Verify Aurora records match source data"""
    import csv
    from pathlib import Path
    
    # Get records for this specific file using the saved file_log_id
    assert hasattr(context, 'file_log_id'), \
        "file_log_id not found in context. Make sure the file verification step ran first."
    
    # Remove any quotes from table_name and file_name
    table_name = table_name.strip('"').strip("'")
    file_name = file_name.strip('"').strip("'")
    
    logger.info(f"DEBUG - table_name parameter: '{table_name}'")
    logger.info(f"DEBUG - file_name parameter: '{file_name}'")
    logger.info(f"DEBUG - file_log_id: {context.file_log_id}")
    
    # Get file path using the same logic as file upload step
    s3_helper = S3Helper()
    file_map = s3_helper.get_file_map()
    normalized_file = file_name.strip('"\'').lower()
    
    if normalized_file not in file_map:
        available = ', '.join(file_map.keys())
        raise ValueError(
            f"❌ Test file '{file_name}' not recognized. "
            f"Available options: {available}"
        )
    
    test_file_path = file_map[normalized_file]
    
    # Navigate to project root (from tests/e2e/steps -> tests -> project root)
    local_file = Path(__file__).parent.parent.parent.parent / test_file_path
    if not local_file.exists():
        raise FileNotFoundError(f"Test file not found at: {local_file}")
    
    logger.info(f"DEBUG - Reading file from: {local_file}")
    
    # Determine file type and count rows accordingly
    file_extension = local_file.suffix.lower()
    
    if file_extension == '.csv':
        # Count CSV rows (excluding header)
        with open(local_file, 'r', encoding='utf-8') as csvfile:
            csv_reader = csv.reader(csvfile)
            next(csv_reader, None)  # Skip header
            expected_row_count = sum(1 for row in csv_reader)
    
    elif file_extension == '.txt':
        # Count non-empty lines in txt file (excluding header if present)
        with open(local_file, 'r', encoding='utf-8') as txtfile:
            lines = txtfile.readlines()
            # Skip first line if it looks like a header (you can adjust this logic)
            # Option 1: Always skip first line
            expected_row_count = len([line for line in lines[1:] if line.strip()])
            
            # Option 2: Count all non-empty lines (no header assumption)
            # expected_row_count = len([line for line in lines if line.strip()])
    
    elif file_extension in ['.tsv', '.tab']:
        # Count tab-delimited rows (excluding header)
        with open(local_file, 'r', encoding='utf-8') as tsvfile:
            tsv_reader = csv.reader(tsvfile, delimiter='\t')
            next(tsv_reader, None)  # Skip header
            expected_row_count = sum(1 for row in tsv_reader)
    
    elif file_extension == '.json':
        # Count JSON array items or lines
        import json
        with open(local_file, 'r', encoding='utf-8') as jsonfile:
            data = json.load(jsonfile)
            if isinstance(data, list):
                expected_row_count = len(data)
            else:
                raise ValueError(f"Expected JSON array in {file_name}, got {type(data)}")
    
    elif file_extension in ['.xlsx', '.xls']:
        # Count Excel rows (excluding header)
        try:
            import openpyxl
            workbook = openpyxl.load_workbook(local_file)
            sheet = workbook.active
            # Count rows with data (excluding header row)
            expected_row_count = sheet.max_row - 1
        except ImportError:
            raise ImportError("openpyxl is required to read Excel files. Install with: pip install openpyxl")
    
    else:
        raise ValueError(
            f"Unsupported file type: {file_extension}. "
            f"Supported types: .csv, .txt, .tsv, .tab, .json, .xlsx, .xls"
        )
    
    logger.info(f"DEBUG - Expected row count from {file_extension} file: {expected_row_count}")
    
    # Get records from Aurora
    actual_row_count = context.aurora_helper.get_record_count(
        table_name,
        where_clause=f"file_log_id = {context.file_log_id}"
    )
    
    #actual_row_count = len(records)
    logger.info(f"DEBUG - Actual row count from Aurora: {actual_row_count}")
    
    assert actual_row_count == expected_row_count, \
        f"Record count mismatch: Expected {expected_row_count} records from source {file_extension} file '{file_name}', " \
        f"but found {actual_row_count} records with file_log_id={context.file_log_id} in table '{table_name}'"
    
    logger.info(f"✅ Record count matches: {actual_row_count} records found for file_log_id={context.file_log_id}")

@step('the following columns in the {table_name} table should have the value {expected_value} for each record associated with the {file_name} file:')
def step_verify_column_values(context, table_name, expected_value, file_name):
    """Verify specific columns have expected values for records"""
    
    # Get records for this specific file using the saved file_log_id
    assert hasattr(context, 'file_log_id'), \
        "file_log_id not found in context. Make sure the file verification step ran first."
    
    # Remove any quotes from table_name and file_name
    table_name = table_name.strip('"').strip("'")
    file_name = file_name.strip('"').strip("'")
    expected_value = expected_value.strip('"').strip("'")
    
    #logger.info(f"DEBUG - table_name parameter: '{table_name}'")
    #logger.info(f"DEBUG - file_name parameter: '{file_name}'")
    #logger.info(f"DEBUG - expected_value: '{expected_value}'")
    logger.info(f"DEBUG - file_log_id: {context.file_log_id}")
    
    # Extract column names from context.table
    assert hasattr(context, 'table'), \
        "No data table found. Make sure columns are specified in the step."
    
    columns_to_check = [row[0] for row in context.table]
    #logger.info(f"DEBUG - Columns to check: {columns_to_check}")
    
    # Get records from Aurora
    records = context.aurora_helper.get_records(
        table_name,
        where_clause=f"file_log_id = {context.file_log_id}"
    )
    
    actual_row_count = len(records)
    #logger.info(f"DEBUG - Found {actual_row_count} records with file_log_id={context.file_log_id}")
    
    assert actual_row_count > 0, \
        f"No records found with file_log_id={context.file_log_id} in table '{table_name}'"
    
    # Keep expected value as string for datatype-agnostic comparison
    expected_val = expected_value
    logger.info(f"DEBUG - Expected value: '{expected_val}'")

    # Verify each column for each record
    mismatches = []
    for record in records:
        for column in columns_to_check:
            if column not in record:
                mismatches.append(f"Column '{column}' not found in record")
                continue
            
            actual_val = record[column]
            # Compare as strings to be datatype agnostic
            if str(actual_val) != str(expected_val):
                mismatches.append(
                    f"Record mismatch: column '{column}' has value {actual_val} (type: {type(actual_val).__name__}) "
                    f"(expected {expected_val})"
                )
    
    # Verify each column for each record
    mismatches = []
    for record in records:
        for column in columns_to_check:
            if column not in record:
                mismatches.append(f"Column '{column}' not found in record")
                continue
            
            actual_val = record[column]
            if actual_val != expected_val:
                mismatches.append(
                    f"Record mismatch: column '{column}' has value {actual_val} "
                    f"(expected {expected_val})"
                )
    
    assert len(mismatches) == 0, \
        f"Column value mismatches found for file_log_id={context.file_log_id}:\n" + \
        "\n".join(mismatches[:10]) + \
        (f"\n... and {len(mismatches) - 10} more" if len(mismatches) > 10 else "")
    
    logger.info(
        f"✅ All {len(columns_to_check)} columns have the expected value '{expected_val}' "
        f"across {actual_row_count} records for file_log_id={context.file_log_id}"
    )


@step('the following columns in the most recent record of the {table_name} table should have the expected values:')
def step_verify_recent_record_column_values(context, table_name):
    """Verify specific columns have expected values in the most recent record"""
    
    # Remove any quotes from table_name
    table_name = table_name.strip('"').strip("'")
    
    logger.info(f"DEBUG - table_name parameter: '{table_name}'")
    
    # Extract column names and expected values from context.table
    assert hasattr(context, 'table'), \
        "No data table found. Make sure columns and expected values are specified in the step."
    
    # Expecting format: | column_name | expected_value |
    columns_and_values = {row['column_name']: row['expected_value'] for row in context.table}
    logger.info(f"DEBUG - Columns and expected values: {columns_and_values}")
    
    # Get the most recent record from the table (ordered by descending ID)
    records = context.aurora_helper.get_records(
        table_name,
        where_clause="1=1 ORDER BY created_date DESC",
        limit=1
    )
    
    assert len(records) > 0, f"No records found in table '{table_name}'"
    
    last_record = records[0]
    logger.info(f"DEBUG - Most recent record columns: {list(last_record.keys())}")
    logger.info(f"DEBUG - Most recent record data: {last_record}")
    
    # Verify each column has the expected value
    mismatches = []
    for column, expected_value in columns_and_values.items():
        # Strip quotes from expected value
        expected_val = expected_value.strip('"').strip("'")
        
        if column not in last_record:
            mismatches.append(
                f"Column '{column}' not found in record. "
                f"Available columns: {list(last_record.keys())}"
            )
            continue
        
        actual_val = last_record[column]
        
        # Compare as strings to be datatype agnostic
        if str(actual_val) != str(expected_val):
            mismatches.append(
                f"Column '{column}' has value '{actual_val}' (type: {type(actual_val).__name__}) "
                f"but expected '{expected_val}'"
            )
    
    assert len(mismatches) == 0, \
        f"Column value mismatches found in most recent record:\n" + "\n".join(mismatches)
    
    logger.info(
        f"✅ All {len(columns_and_values)} columns have expected values "
        f"in the most recent record of table '{table_name}'"
    )


#==================================================================================================================================