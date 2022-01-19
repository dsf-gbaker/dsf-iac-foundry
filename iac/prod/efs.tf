/*
resource "aws_efs_file_system" "foundry-efs" {
  creation_token    = var.efs-creation-token
  performance_mode  = var.efs-performance-mode

  lifecycle_policy {
    transition_to_ia = var.efs-lifecycle-policy
  }
}

resource "aws_efs_mount_target" "foundry-efs-mount" {
  file_system_id = aws_efs_file_system.foundry-efs.id
  subnet_id = aws_subnet.public.id
  security_groups = [aws_security_group.foundry-sg.id]
}

resource "aws_efs_access_point" "foundry-access-point" {
  file_system_id = aws_efs_file_system.foundry-efs.id

  posix_user {
    gid = var.efs-posix-gid
    uid = var.efs-posix-uid
  }

  root_directory {
    path = var.efs-root-path
    creation_info {
      owner_gid   = var.efs-posix-gid
      owner_uid   = var.efs-posix-uid
      permissions = "0777"
    }
  }
}
*/