terraform {
  source = "../../../infrastructure-modules/s3"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  env             = "dev"
  bucket_name     = "dev-bucket-88997766"
  upload_bucket_name  = "dev-upload-bucket-88997766"
}
