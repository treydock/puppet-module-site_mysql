# == Class: site_mysql::mounts
#
# Manage mount points for MySQL instance
#
class site_mysql::mounts {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $site_mysql::manage_lvm {
    if $site_mysql::datadir_pv and $site_mysql::datadir_size {
      lvm::volume { $site_mysql::datadir_lv_name:
        ensure => 'present',
        vg     => $site_mysql::datadir_vg_name,
        pv     => $site_mysql::datadir_pv,
        fstype => $site_mysql::datadir_fstype,
        size   => $site_mysql::datadir_size,
        before => Mount['mysql-datadir'],
      }
    }
  }

  if $site_mysql::manage_mounts {
    mount { 'mysql-datadir':
      ensure  => 'mounted',
      name    => $site_mysql::datadir_path,
      atboot  => true,
      device  => $site_mysql::datadir_device_real,
      fstype  => $site_mysql::datadir_fstype,
      options => $site_mysql::datadir_mount_options,
      require => Class['mysql::server::install'],
      before  => Class['mysql::server::config'],
    }

    file { 'mysql-tmpdir':
      ensure  => 'directory',
      path    => $site_mysql::tmpdir_path,
      owner   => 'mysql',
      group   => 'mysql',
      require => Class['mysql::server::install'],
      before  => Mount['mysql-tmpdir'],
    }

    mount { 'mysql-tmpdir':
      ensure  => 'mounted',
      name    => $site_mysql::tmpdir_path,
      atboot  => true,
      device  => $site_mysql::tmpdir_device,
      fstype  => $site_mysql::tmpdir_fstype,
      options => $site_mysql::tmpdir_mount_options,
      before  => Class['mysql::server::config'],
    }
  }

}
