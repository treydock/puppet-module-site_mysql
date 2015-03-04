require 'spec_helper'

describe 'site_mysql::backup' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should compile.with_all_deps }
    end
  end

  let(:facts) do
    on_supported_os['centos-7-x86_64']
  end
  let(:params) {{ :backup_pv => '/dev/vdc' }}
  let(:pre_condition) do
    "class { 'mysql::server::backup':
      backupuser      => 'backup',
      backuppassword  => 'backup',
      backupdir       => '/opt/mysql_backups',
    }"
  end

  it { should create_class('site_mysql::backup') }

  it do
    should contain_lvm__volume('lv_mysql_backup').with({
      :ensure => 'present',
      :vg     => 'vg_mysql_backup',
      :pv     => '/dev/vdc',
      :fstype => 'xfs',
      :size   => nil,
      :before => 'Mount[mysql-backupdir]',
    })
  end

  it do
    should contain_mount('mysql-backupdir').with({
      :ensure  => 'mounted',
      :name    => '/opt/mysql_backups',
      :atboot  => 'true',
      :device  => '/dev/vg_mysql_backup/lv_mysql_backup',
      :fstype  => 'xfs',
      :options => 'noatime,nodiratime,nobarrier,defaults',
      :require => 'File[mysqlbackupdir]',
    })
  end

end
