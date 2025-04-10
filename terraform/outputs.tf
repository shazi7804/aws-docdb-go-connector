output "connection_string" {
  description = "MongoDB connection string for DocumentDB"
  value       = "mongodb://${var.master_username}:${var.master_password}@${aws_docdb_cluster.docdb.endpoint}:${aws_docdb_cluster.docdb.port}/?ssl=true&retryWrites=false"
  sensitive   = true
}

output "connection_details" {
  description = "DocumentDB connection details"
  value = {
    endpoint = aws_docdb_cluster.docdb.endpoint
    port     = aws_docdb_cluster.docdb.port
    username = var.master_username
  }
}
