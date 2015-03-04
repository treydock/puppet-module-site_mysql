# == Class: site_mysql::mounts
#
# Manage mount points for MySQL instance
#
class site_mysql::backup (
  $backup_pv,
  $manage_mounts        = true,
  $manage_lvm           = true,
  $backup_device        = undef,
  $backup_path          = undef,
  $backup_fstype        = 'xfs',
  $backup_mount_options = 'noatime,nodiratime,nobarrier,defaults',
  $backup_lv_name       = 'lv_mysql_backup',
  $backup_vg_name       = 'vg_mysql_backup',
  $backup_size          = undef,
  $backup_extents       = undef,
) {

  validate_bool($manage_mounts, $manage_lvm)

  include mysql::server
  include mysql::server::backup

  $backup_path_real   = pick($backup_path, $mysql::server::backup::backupdir)
  $backup_device_real = pick($backup_device, "/dev/${backup_vg_name}/${backup_lv_name}")

  if $manage_lvm {
    lvm::volume { $backup_lv_name:
      ensure  => 'present',
      vg      => $backup_vg_name,
      pv      => $backup_pv,
      fstype  => $backup_fstype,
      size    => $backup_size,
      extents => $backup_extents,
      before  => Mount['mysql-backupdir'],
    }
  }

  if $manage_mounts {
    exec { 'mysql-backupdir':
      path    => '/bin:/usr/bin:/sbin:/usr/sbin',
      command => "mkdir -p ${backup_path_real}",
      creates => $backup_path_real,
    }->
    mount { 'mysql-backupdir':
      ensure  => 'mounted',
      name    => $backup_path_real,
      atboot  => true,
      device  => $backup_device_real,
      fstype  => $backup_fstype,
      options => $backup_mount_options,
      before  => File['mysqlbackupdir'],
    }
  }

}
