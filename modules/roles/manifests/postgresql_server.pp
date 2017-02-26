class roles::postgresql_server {
	file { "/usr/local/bin/pg-backup-file":
		mode    => 555,
		source  => "puppet:///modules/roles/postgresql_server/pg-backup-file",
	}
	file { "/usr/local/bin/pg-receive-file-from-backup":
		mode    => 555,
		source  => "puppet:///modules/roles/postgresql_server/pg-receive-file-from-backup",
	}
	file { "/etc/dsa/pg-backup-file.conf":
		content => template('roles/postgresql_server/pg-backup-file.conf.erb'),
	}

	if ! $::postgresql_key {
		exec { 'create-postgresql-key':
			command => '/bin/su - postgres -c \'mkdir -p -m 02700 .ssh && ssh-keygen -C "`whoami`@`hostname` (`date +%Y-%m-%d`)" -P "" -f .ssh/id_rsa -q\'',
			onlyif  => '/usr/bin/getent passwd postgres > /dev/null && ! [ -e /var/lib/postgresql/.ssh/id_rsa ]'
		}
	}
}
