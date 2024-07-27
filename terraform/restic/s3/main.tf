variable "bucket_name" {
  type = string
}

resource "aws_s3_bucket" "restic" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "restic" {
  bucket = aws_s3_bucket.restic.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "restic" {
  bucket = aws_s3_bucket.restic.bucket
  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

output "bucket_arn" {
  value = aws_s3_bucket.restic.arn
}
