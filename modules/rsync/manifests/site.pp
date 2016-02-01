define rsync::site (
	$bind='',
	$bind6='',
	$source='',
	$content='',
	$fname='',
	$max_clients=200,
	$ensure=present,
	$sslname='',
	$sslport=1873
){

	include rsync

	if ! $fname {
		$fname_real = "/etc/rsyncd-${name}.conf"
	} else {
		$fname_real = $fname
	}
	case $ensure {
		present,absent: {}
		default: { fail ( "Invald ensure `${ensure}' for ${name}" ) }
	}

	if ($source and $content) {
		fail ( "Can't define both source and content for ${name}" )
	}

	if $source {
		file { $fname_real:
			ensure => $ensure,
			source => $source
		}
	} elsif $content {
		file { $fname_real:
			ensure  => $ensure,
			content => $content,
		}
	} else {
		fail ( "Can't find config for ${name}" )
	}

	xinetd::service { "rsync-${name}":
		bind        => $bind,
		id          => "${name}-rsync",
		server      => '/usr/bin/rsync',
		service     => 'rsync',
		server_args => "--daemon --config=${fname_real}",
		ferm        => false,
		instances   => $max_clients,
		require     => File[$fname_real]
	}

	if $bind6 != '' {
		if $bind == '' {
			fail("Cannot listen on * and a specific ipv6 address")
		}
		xinetd::service { "rsync-${name}6":
			bind        => $bind6,
			id          => "${name}-rsync6",
			server      => '/usr/bin/rsync',
			service     => 'rsync',
			server_args => "--daemon --config=${fname_real}",
			ferm        => false,
			instances   => $max_clients,
			require     => File[$fname_real]
		}
	}

	if $sslname != '' {
		file { "/etc/rsyncd-${name}-stunnel.conf":
			content => template('rsync/rsyncd-stunnel.conf.erb')
		}
		@ferm::rule { "rsync-${name}-ssl":
			domain      => '(ip ip6)',
			description => 'Allow rsync access',
			rule        => "&SERVICE(tcp, $sslport)",
		}
		xinetd::service { "rsync-${name}-ssl":
			bind        => $bind,
			id          => "rsync-${name}-ssl",
			server      => '/usr/bin/stunnel4',
			server_args => "/etc/rsyncd-${name}-stunnel.conf",
			service     => "rsync-ssl",
			type        => 'UNLISTED',
			port        => "$sslport",
			ferm        => true,
			instances   => $max_clients,
			require     => File["/etc/rsyncd-${name}-stunnel.conf"],
		}
		if $bind6 != '' {
			xinetd::service { "rsync-${name}-ssl6":
				bind        => $bind6,
				id          => "rsync-${name}-ssl6",
				server      => '/usr/bin/stunnel4',
				server_args => "/etc/rsyncd-${name}-stunnel.conf",
				service     => "rsync-ssl",
				type        => 'UNLISTED',
				port        => "$sslport",
				ferm        => true,
				instances   => $max_clients,
				require     => File["/etc/rsyncd-${name}-stunnel.conf"],
			}
		}
	}

	Service['rsync']->Service['xinetd']
}
