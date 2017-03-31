define vsftpd::site (
	$root,
	$bind='',
	$chown_user='',
	$writable=false,
	$writable_other=false,
	$banner="${name} FTP Server",
	$max_clients=100,
	$logfile="/var/log/ftp/vsftpd-${name}.debian.org.log",
	$ensure=present
){

	include vsftpd

	case $ensure {
		present,absent: {}
		default: { fail ( "Invald ensure `$ensure' for $name" ) }
	}

	$ftpsite = $name

	$fname = "/etc/vsftpd-${name}.conf"

	file { $fname:
		ensure  => $ensure,
		content => template('vsftpd/vsftpd.conf.erb')
	}

	file { "/etc/logrotate.d/vsftpd-${name}":
		ensure => absent
	}

	munin::check { "vsftpd-${name}":
		ensure => $ensure,
		script => 'vsftpd'
	}
	munin::conf { "vsftpd-${name}":
		ensure  => $ensure,
		content => template('vsftpd/munin.erb')
	}

	# We don't need a firewall rule because it's added in vsftp.pp
	xinetd::service { "vsftpd-${name}":
		ensure      => $ensure,
		bind        => $bind,
		id          => "${name}-ftp",
		server      => '/usr/sbin/vsftpd',
		service     => 'ftp',
		server_args => $fname,
		ferm        => false,
		instances   => $max_clients,
		require     => File[$fname]
	}

	Service['vsftpd']->Service['xinetd']
}
