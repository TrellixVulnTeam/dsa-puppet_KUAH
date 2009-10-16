define enable_module($module) {
        exec { "/usr/sbin/a2enmod $module": }
}

class apache2 {
	package {
		apache2: ensure => installed;
		logrotate: ensure => installed;
	}

        enable_module {
                "info": module => info;
                "status": module => status;
        }

	file {
		"/etc/apache2/conf.d/ressource-limits":
			content => template("apache2/ressource-limits.erb"),
			require => Package["apache2"],
			notify  => Exec["apache2 reload"];
		"/etc/apache2/conf.d/security":
			source  => [ "puppet:///apache2/per-host/$fqdn/etc/apache2/conf.d/security",
			             "puppet:///apache2/common/etc/apache2/conf.d/security" ],
			require => Package["apache2"],
			notify  => Exec["apache2 reload"];
		"/etc/apache2/conf.d/local-serverinfo":
			source  => [ "puppet:///apache2/per-host/$fqdn/etc/apache2/conf.d/local-serverinfo",
			             "puppet:///apache2/common/etc/apache2/conf.d/local-serverinfo" ],
			require => Package["apache2"],
			notify  => Exec["apache2 reload"];
		"/etc/apache2/conf.d/server-status":
			source  => [ "puppet:///apache2/per-host/$fqdn/etc/apache2/conf.d/server-status",
			             "puppet:///apache2/common/etc/apache2/conf.d/server-status" ],
			require => Package["apache2"],
			notify  => Exec["apache2 reload"];

		"/etc/apache2/sites-available/default-debian.org":
			source  => [ "puppet:///apache2/per-host/$fqdn/etc/apache2/sites-available/default-debian.org",
			             "puppet:///apache2/common/etc/apache2/sites-available/default-debian.org" ],
			require => Package["apache2"],
			notify  => Exec["apache2 reload"];

		"/etc/logrotate.d/apache2":
			source  => [ "puppet:///apache2/per-host/$fqdn/etc/logrotate.d/apache2",
			             "puppet:///apache2/common/etc/logrotate.d/apache2" ];

		"/srv/www":
			mode    => 755,
			ensure  => directory;
		"/srv/www/default.debian.org":
			mode    => 755,
			ensure  => directory;
		"/srv/www/default.debian.org/htdocs":
			mode    => 755,
			ensure  => directory;
		"/srv/www/default.debian.org/htdocs/index.html":
			content => template("apache2/default-index.html");

		# sometimes this is a symlink
		#"/var/log/apache2":
		#	mode    => 755,
		#	ensure  => directory;
	}

	exec { "apache2 reload":
		path        => "/etc/init.d:/usr/bin:/usr/sbin:/bin:/sbin",
		refreshonly => true,
	}
}
