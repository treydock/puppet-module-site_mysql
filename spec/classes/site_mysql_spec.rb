require 'spec_helper'

describe 'site_mysql' do
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
  let(:params) {{}}

  it { should create_class('site_mysql') }
  it { should contain_anchor('site_mysql::begin').that_comes_before('Class[site_mysql::mounts]') }
  it { should contain_class('site_mysql::mounts').that_comes_before('Anchor[site_mysql::end]') }
  it { should contain_anchor('site_mysql::end') }

  describe 'site_mysql::mounts' do
    it do
      should_not contain_lvm__volume('lv_mysql')
    end

    context 'when datadir_pv and datadir_size are defined' do
      let(:params) {{ :datadir_pv => '/dev/vdb', :datadir_size => '50G' }}

      it do
        should contain_lvm__volume('lv_mysql').with({
          :ensure => 'present',
          :vg     => 'vg_mysql',
          :pv     => '/dev/vdb',
          :fstype => 'xfs',
          :size   => '50G',
          :before => 'Mount[mysql-datadir]',
        })
      end
    end

    it do
      should contain_exec('mysql-datadir').with({
        :command  => 'mkdir -p /var/lib/mysql',
        :creates  => '/var/lib/mysql',
        :before   => 'Mount[mysql-datadir]',
      })
    end

    it do
      should contain_mount('mysql-datadir').with({
        :ensure  => 'mounted',
        :name    => '/var/lib/mysql',
        :atboot  => 'true',
        :device  => '/dev/vg_mysql/lv_mysql',
        :fstype  => 'xfs',
        :options => 'noatime,nodiratime,nobarrier,defaults',
        :before  => 'File[mysql-datadir]',
      })
    end

    it do
      should contain_file('mysql-datadir').with({
        :ensure   => 'directory',
        :path     => '/var/lib/mysql',
        :owner    => 'mysql',
        :group    => 'mysql',
        :require  => 'Class[Mysql::Server::Install]',
        :before   => 'Class[Mysql::Server::Config]',
      })
    end

    it do
      should contain_exec('mysql-tmpdir').with({
        :command  => 'mkdir -p /var/cache/mysql',
        :creates  => '/var/cache/mysql',
        :before   => 'Mount[mysql-tmpdir]',
      })
    end

    it do
      should contain_mount('mysql-tmpdir').with({
        :ensure  => 'mounted',
        :name    => '/var/cache/mysql',
        :atboot  => 'true',
        :device  => 'tmpfs',
        :fstype  => 'tmpfs',
        :options => 'rw,uid=mysql,gid=mysql,size=512M,nr_inodes=10k,mode=0755',
        :before  => 'File[mysql-tmpdir]',
      })
    end

    it do
      should contain_file('mysql-tmpdir').with({
        :ensure   => 'directory',
        :path     => '/var/cache/mysql',
        :owner    => 'mysql',
        :group    => 'mysql',
        :require  => 'Class[Mysql::Server::Install]',
        :before   => 'Class[Mysql::Server::Config]',
      })
    end
  end

end
