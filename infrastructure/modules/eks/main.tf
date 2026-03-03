resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  tags = var.tags
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name}-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.node_subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.instance_types
  tags           = var.tags
}

resource "aws_eks_addon" "addons" {
  for_each = toset(var.addons)

  cluster_name = aws_eks_cluster.this.name
  addon_name   = each.value

  depends_on = [aws_eks_node_group.this]
  tags       = var.tags
}
