data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

resource "aws_eks_node_group" "gpu" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "gpu"
  node_role_arn   = aws_eks_cluster.cluster.role_arn
  subnet_ids      = aws_eks_cluster.cluster.vpc_config.subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
}
