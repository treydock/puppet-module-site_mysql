# == Class: site_mysql
#
class site_mysql (
  $ensure                 = 'present',
  $manage_lvm             = true,
  $manage_mounts          = true,
  $datadir_pv             = undef,
  $datadir_vg_name        = 'vg_mysql',
  $datadir_lv_name        = 'lv_mysql',
  $datadir_size           = undef,
  $datadir_path           = '/var/lib/mysql',
  $datadir_device         = undef,
  $datadir_fstype         = 'xfs',
  $datadir_mount_options  = 'noatime,nodiratime,nobarrier,defaults',
  $tmpdir_path            = '/var/cache/mysql',
  $tmpdir_device          = 'tmpfs',
  $tmpdir_fstype          = 'tmpfs',
  $tmpdir_mount_options   = 'rw,uid=mysql,gid=mysql,size=512M,nr_inodes=10k,mode=0755',
) {

  case $ensure {
    'present': {
      # Do nothing
    }
    'absent': {
      # Do nothing
    }
    default: {
      fail("${module_name}: ensure parameter must be 'present' or 'absent', ${ensure} given.")
    }
  }

  validate_bool($manage_lvm, $manage_mounts)

  $datadir_device_real = pick($datadir_device, "/dev/${datadir_vg_name}/${datadir_lv_name}")

  include mysql::server

  anchor { 'site_mysql::begin': }->
  class { 'site_mysql::mounts': }->
  anchor { 'site_mysql::end': }

}
