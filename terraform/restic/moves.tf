moved {
  from = module.s3_shared.aws_s3_bucket.restic
  to   = module.s3.aws_s3_bucket.restic
}
moved {
  from = module.s3_shared.aws_s3_bucket_versioning.restic
  to   = module.s3.aws_s3_bucket_versioning.restic
}
