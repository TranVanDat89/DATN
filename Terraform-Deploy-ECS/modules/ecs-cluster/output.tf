output "cluster_name" {
  value = aws_ecs_cluster.final-assignment_ecs_cluster.name
}

output "be_service_name" {
  value = aws_ecs_service.backend_service.name
}