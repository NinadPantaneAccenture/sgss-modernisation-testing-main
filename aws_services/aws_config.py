import json
import os
import boto3
from datetime import datetime
from functools import lru_cache
from dotenv import load_dotenv

# Load environment variables from .env file
# load_dotenv()

# Prefer DOTENV_PATH passed by GitHub Actions; fallback to envSIT if not provided
dotenv_path = os.getenv("DOTENV_PATH", "envSIT")
load_dotenv(dotenv_path=dotenv_path)
 

class TestConfig:
    """Test config for S3 input, Glue job, and Aurora credentials via Secrets Manager.
    
    All sensitive configuration is loaded from environment variables.
    See .env.example for required environment variables.
    """

    # ======================
    # AWS Credentials (from environment)
    # ======================
    AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
    AWS_REGION = os.getenv('AWS_REGION', 'eu-west-2')

    # ======================
    # S3 Configuration
    # ======================
    S3_BUCKET_NAME = os.getenv('S3_BUCKET_NAME')
    S3_INPUT_PREFIX = os.getenv('S3_INPUT_PREFIX', 'PreRegFileSrcWeb/')

    # ======================
    # Glue Job Configuration
    # ======================
    GLUE_JOB_NAME = os.getenv('GLUE_JOB_NAME')
    GLUE_CLEAN_JOB_NAME = os.getenv('GLUE_CLEAN_JOB_NAME')
    GLUE_JOB_TIMEOUT = int(os.getenv('GLUE_JOB_TIMEOUT', '600'))
    GLUE_POLL_INTERVAL = int(os.getenv('GLUE_POLL_INTERVAL', '10'))

    # ======================
    # Aurora / Secrets Manager Configuration
    # ======================
    AURORA_SECRET_NAME = os.getenv('AURORA_SECRET_NAME')
    AURORA_DATABASE = os.getenv('AURORA_DATABASE')
    AURORA_TABLE_NAME = os.getenv('AURORA_TABLE_NAME', 'ods.omd_file_log')
    AURORA_PORT = int(os.getenv('AURORA_PORT', '5432'))
    AURORA_RESOURCE_ARN = os.getenv('AURORA_RESOURCE_ARN')



    # ======================
    # Test Runtime
    # ======================
    @classmethod
    def new_test_run_id(cls):
        return datetime.utcnow().strftime("%Y%m%d_%H%M%S")

    # ======================
    # AWS Session
    # ======================
    @classmethod
    @lru_cache(maxsize=1)
    def aws_session(cls):
        return boto3.session.Session(
            aws_access_key_id=cls.AWS_ACCESS_KEY_ID,
            aws_secret_access_key=cls.AWS_SECRET_ACCESS_KEY,
            region_name=cls.AWS_REGION,
        )

    # ======================
    # S3 Helpers
    # ======================
    @classmethod
    def get_test_file_key(cls, filename=None):
        if filename is None:
            filename = f"test_file_{cls.new_test_run_id()}.csv"
        return f"{cls.S3_INPUT_PREFIX}{filename}"

    # ======================
    # Glue Helpers
    # ======================
    @classmethod
    def get_glue_job_arguments(cls, s3_key):
        return {
            "--input_path": f"s3://{cls.S3_BUCKET_NAME}/{s3_key}",
            "--aurora_secret_name": cls.AURORA_SECRET_NAME,
            "--aurora_table": cls.AURORA_TABLE_NAME,
        }

    # ======================
    # Aurora Helpers
    # ======================
    @classmethod
    @lru_cache(maxsize=1)
    def get_aurora_credentials(cls):
        """
        Fetch Aurora credentials from AWS Secrets Manager
        """
        client = cls.aws_session().client("secretsmanager")

        response = client.get_secret_value(
            SecretId=cls.AURORA_SECRET_NAME
        )

        secret = json.loads(response["SecretString"])

        return {
            #"host": secret["host"],
            "port": secret.get("port", cls.AURORA_PORT),
            "database": secret.get("dbname"),
            #"username": secret.get("DB_USER"),
            #"password": secret.get("DB_PASSWORD"),
        }

    # ======================
    # Validation
    # ======================
    @classmethod
    def validate_config(cls):
        required = {
            "AWS_ACCESS_KEY_ID": cls.AWS_ACCESS_KEY_ID,
            "AWS_SECRET_ACCESS_KEY": cls.AWS_SECRET_ACCESS_KEY,
            "AWS_REGION": cls.AWS_REGION,
            "S3_BUCKET_NAME": cls.S3_BUCKET_NAME,
            "GLUE_JOB_NAME": cls.GLUE_JOB_NAME,
            "AURORA_SECRET_NAME": cls.AURORA_SECRET_NAME,
        }

        missing = [k for k, v in required.items() if not v]
        if missing:
            raise ValueError(f"Missing required config: {', '.join(missing)}")

        # Validate we can read the secret
        cls.get_aurora_credentials()
        
        return True
        
