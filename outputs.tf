output "website_url" {
  description = "Website URL (HTTPS)"
  value       = aws_cloudfront_distribution.website_distribution
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.website_distribution.id
}