resource "random_id" "random_hex" {
  byte_length = 8
}

resource "aws_s3_bucket" "this" {
  bucket = format("%s-%s", var.bucket_name, random_id.random_hex.hex)
  tags = {
    Name        = "my-bucket"
    Environment = "Dev"
  }
}
