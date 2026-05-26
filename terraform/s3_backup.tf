# 1. Random string generator to guarantee a globally unique bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 2. Core S3 Bucket Configuration
resource "aws_s3_bucket" "backups" {
  bucket        = "certara-application-backups-${random_id.bucket_suffix.hex}"
  force_destroy = true # Allows clean testing teardown even if objects exist

  tags = {
    Name        = "certara-application-backups"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# 3. Security Best Practice: Block all public access completely
resource "aws_s3_bucket_public_access_block" "backups" {
  bucket = aws_s3_bucket.backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 4. Security Best Practice: Enforce Default Server-Side Encryption (SSE-KMS)
resource "aws_s3_bucket_server_side_encryption_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms" # Using AWS managed KMS key for S3
    }
    bucket_key_enabled = true # Reduces KMS API costs by up to 99%
  }
}

# 5. Cost Best Practice: 180-Day Automated Lifecycle Management
resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    id     = "backup-retention-policy"
    status = "Enabled"
    
    # FIX: Explicitly tells Terraform this rule applies to ALL objects in the bucket
    filter {}

    # Optimization: Transition to a cheaper storage tier after 30 days
    transition {
      days          = 30
      storage_class = "STANDARD_IA" # Infrequent Access (cheaper storage fee)
    }

    # Strict compliance requirement: Permanent hard deletion at exactly 180 days
    expiration {
      days = 180
    }

    # Clean up incomplete multi-part uploads to prevent hidden storage costs
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# 6. Cross-Account Architecture Best Practice: Object Ownership Lock
resource "aws_s3_bucket_ownership_controls" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# 7. Cross-Account Authorization: Bucket Access Policy
resource "aws_s3_bucket_policy" "allow_cross_account_backup" {
  bucket     = aws_s3_bucket.backups.id
  depends_on = [aws_s3_bucket_public_access_block.backups]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountBackupUpload"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:role/backup_uploader"
        }
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "${aws_s3_bucket.backups.arn}/*"
      },
      {
        Sid    = "EnforceSSLOnly" # Security Best Practice: In-transit encryption enforcement
        Effect = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.backups.arn,
          "${aws_s3_bucket.backups.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# Output the generated name so you can verify it
output "backup_bucket_name" {
  value       = aws_s3_bucket.backups.id
  description = "The globally unique name of the backup bucket"
}
