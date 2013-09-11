class roles::pubsub::entities {
	include roles::pubsub::params

	$admin_password  = $roles::pubsub::params::admin_password
	$ftp_password    = $roles::pubsub::params::ftp_password
	$buildd_password = $roles::pubsub::params::buildd_password
	$wbadm_password  = $roles::pubsub::params::wbadm_password

	rabbitmq_user { 'admin':
		admin    => true,
		password => $admin_password,
		provider => 'rabbitmqctl',
	}

	rabbitmq_user { 'ftpteam':
		admin    => true,
		password => $ftp_password,
		provider => 'rabbitmqctl',
	}

	rabbitmq_user { 'buildd':
		admin    => true,
		password => $buildd_password,
		provider => 'rabbitmqctl',
	}

	rabbitmq_user { 'wbadm':
		admin    => true,
		password => $wbadm_password,
		provider => 'rabbitmqctl',
	}

	rabbitmq_vhost { 'packages':
		ensure   => present,
		provider => 'rabbitmqctl',
	}

	rabbitmq_vhost { 'buildd':
		ensure   => present,
		provider => 'rabbitmqctl',
	}

	rabbitmq_user_permissions { 'admin@/':
		configure_permission => '.*',
		read_permission      => '.*',
		write_permission     => '.*',
		provider             => 'rabbitmqctl',
		require              => Rabbitmq_user['admin']
	}

	rabbitmq_user_permissions { 'admin@buildd':
		configure_permission => '.*',
		read_permission      => '.*',
		write_permission     => '.*',
		provider             => 'rabbitmqctl',
		require              => [
			Rabbitmq_user['admin'],
			Rabbitmq_vhost['buildd']
		]
	}
	rabbitmq_user_permissions { 'admin@packages':
		configure_permission => '.*',
		read_permission      => '.*',
		write_permission     => '.*',
		provider             => 'rabbitmqctl',
		require              => [
			Rabbitmq_user['admin'],
			Rabbitmq_vhost['packages']
		]
	}

	rabbitmq_user_permissions { 'ftpteam@packages':
		configure_permission => '.*',
		read_permission      => '.*',
		write_permission     => '.*',
		provider             => 'rabbitmqctl',
		require              => [
			Rabbitmq_user['ftpteam'],
			Rabbitmq_vhost['packages']
		]
	}

	rabbitmq_user_permissions { 'wbadm@packages':
		read_permission      => 'unchecked',
		write_permission     => 'wbadm',
		provider             => 'rabbitmqctl',
		require              => [
			Rabbitmq_user['wbadm'],
			Rabbitmq_vhost['packages']
		]
	}

	rabbitmq_user_permissions { 'buildd@buildd':
		configure_permission => '.*',
		read_permission      => '.*',
		write_permission     => '.*',
		provider             => 'rabbitmqctl',
		require              => [
			Rabbitmq_user['buildd'],
			Rabbitmq_vhost['buildd']
		]
	}

	rabbitmq_user_permissions { 'wbadm@buildd':
		configure_permission => '.*',
		read_permission      => '.*',
		write_permission     => '.*',
		provider             => 'rabbitmqctl',
		require              => [
			Rabbitmq_user['wbadm'],
			Rabbitmq_vhost['buildd']
		]
	}

	rabbitmq_policy { 'mirror-buildd':
		vhost   => 'buildd',
		match   => '.*',
		policy  => '{"ha-mode":"all"}',
		require => Rabbitmq_vhost['buildd']
	}

	rabbitmq_policy { 'mirror-packages':
		vhost   => 'packages',
		match   => '.*',
		policy  => '{"ha-mode":"all"}',
		require => Rabbitmq_vhost['packages']
	}

	rabbitmq_plugin { 'rabbitmq_management':
		ensure   => present,
		provider => 'rabbitmqplugins',
		require  => Package['rabbitmq-server'],
		notify   => Service['rabbitmq-server']
	}
	rabbitmq_plugin { 'rabbitmq_management_agent':
		ensure   => present,
		provider => 'rabbitmqplugins',
		require  => Package['rabbitmq-server'],
		notify   => Service['rabbitmq-server']
	}
	rabbitmq_plugin { 'rabbitmq_tracing':
		ensure   => present,
		provider => 'rabbitmqplugins',
		require  => Package['rabbitmq-server'],
		notify   => Service['rabbitmq-server']
	}
	rabbitmq_plugin { 'rabbitmq_management_visualiser':
		ensure   => present,
		provider => 'rabbitmqplugins',
		require  => Package['rabbitmq-server'],
		notify   => Service['rabbitmq-server']
	}

}
