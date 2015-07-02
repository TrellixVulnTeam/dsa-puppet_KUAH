class roles::keystone {

	include roles::openstack::params

	$keystone_dbpass = $roles::openstack::params::keystone_dbpass
	$admin_token     = $roles::openstack::params::admin_token
	$admin_pass      = $roles::openstack::params::admin_pass
	$rabbit_pass      = $roles::openstack::params::rabbit_pass

	class { '::keystone':
		verbose             => true,
		debug               => true,
		sql_connection      => "postgresql://keystone:${keystone_dbpass}@bmdb1.debian.org:5435/keystone",
		catalog_type        => 'sql',
		admin_token         => $admin_token,
		enabled             => false,
		rabbit_host         => undef,
		rabbit_hosts        => ['rapoport.debian.org','rainier.debian.org'],
		rabbit_password     => $rabbit_pass,
		rabbit_userid       => 'openstack',
		rabbit_virtual_host => '/keystone',
		memcache_servers    => ['localhost:11211'],
		cache_backend       => 'keystone.cache.memcache_pool',
	}
	class { 'keystone::roles::admin':
		email    => 'test@puppetlabs.com',
		password => $admin_pass,
	}
	class { 'keystone::endpoint':
		public_url => "https://openstack.bm.debian.org:5000/",
		admin_url  => "https://openstack.bm.debian.org:35357/",
	}

	include apache
	class { 'keystone::wsgi::apache':
		ssl      => true,
		ssl_cert => '/etc/ssl/debian/certs/openstack.bm.debian.org.crt-chained',
		ssl_key  => '/etc/ssl/private/openstack.bm.debian.org.key',

	}
}

