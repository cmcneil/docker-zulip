class zulip::app_frontend {
  include zulip::supervisor
  include zulip::rabbit
  include zulip::nginx
  $web_packages = [ # Needed for memcached usage
                    "python-pylibmc",
                    # Fast JSON parser
                    "python-ujson",
                    # Django dependencies
                    "python-django",
                    "python-django-guardian",
                    "python-django-pipeline",
                    "python-django-bitfield",
                    # Needed for mock objects in decorators
                    "python-mock",
                    # Tornado dependencies
                    "python-tornado",
                    "python-sockjs-tornado",
                    # Needed for our fastcgi setup
                    "python-flup",
                    # Needed for markdown processing
                    "python-markdown",
                    "python-pygments",
                    # Used for Hesiod lookups, etc.
                    "python-dns",
                    # Needed to access our database
                    "postgresql-client-9.3",
                    "python-psycopg2",
                    # Needed for building complex DB queries
                    "python-sqlalchemy",
                    # Needed for integrations
                    "python-twitter",
                    "python-defusedxml",
                    # Needed for the email mirror
                    "python-twisted",
                    "python-html2text",
                    # Needed to access rabbitmq
                    "python-pika",
                    # Needed for timezone work
                    "python-tz",
                    # Needed to parse source maps for error reporting
                    "python-sourcemap",
                    # Needed for redis
                    "python-redis",
                    # Needed for S3 file uploads
                    "python-boto",
                    # Needed to send email
                    "python-mandrill",
                    # Needed to generate diffs for edits
                    "python-diff-match-patch",
                    # Needed for iOS
                    "python-apns-client",
                    # Needed for Android push
                    "python-gcm-client",
                    # Needed for avatar image resizing
                    "python-imaging",
                    # Needed for LDAP support
                    "python-django-auth-ldap",
                    # Needed for Google Apps mobile auth
                    "python-googleapi",
                    # Needed for JWT-based auth
                    "python-pyjwt",
                    # Needed for update prod-static
                    "closure-compiler",
                    ]
  define safepackage ( $ensure = present ) {
    if !defined(Package[$title]) {
      package { $title: ensure => $ensure }
    }
  }
  safepackage { $web_packages: ensure => "installed" }

  file { "/etc/nginx/zulip-include/app":
    require => Package["nginx-full"],
    owner  => "root",
    group  => "root",
    mode => 644,
    source => "puppet:///modules/zulip/nginx/zulip-include-frontend/app",
  }
  file { "/etc/nginx/zulip-include/upstreams":
    require => Package["nginx-full"],
    owner  => "root",
    group  => "root",
    mode => 644,
    source => "puppet:///modules/zulip/nginx/zulip-include-frontend/upstreams",
  }
  file { "/etc/nginx/zulip-include/uploads.types":
    require => Package["nginx-full"],
    owner  => "root",
    group  => "root",
    mode => 644,
    source => "puppet:///modules/zulip/nginx/zulip-include-frontend/uploads.types",
  }
  file { "/etc/nginx/zulip-include/app.d/":
    ensure => directory,
    owner => "root",
    group => "root",
    mode => 755,
  }
  file { "/etc/supervisor/conf.d/zulip.conf":
    require => Package[supervisor],
    ensure => file,
    owner => "root",
    group => "root",
    mode => 644,
    source => "puppet:///modules/zulip/supervisor/conf.d/zulip.conf",
  }
  file { "/home/zulip/tornado":
    ensure => directory,
    owner => "zulip",
    group => "zulip",
    mode => 755,
  }
  file { '/home/zulip/logs':
    ensure => 'directory',
    owner  => 'zulip',
    group  => 'zulip',
  }
  file { '/home/zulip/deployments':
    ensure => 'directory',
    owner  => 'zulip',
    group  => 'zulip',
  }
  file { "/etc/cron.d/email-mirror":
    ensure => absent,
  }
  file { '/etc/log2zulip.conf':
    ensure     => file,
    owner      => "zulip",
    group      => "zulip",
    mode       => 644,
    source     => 'puppet:///modules/zulip/log2zulip.conf',
  }
  file { '/etc/log2zulip.zuliprc':
    ensure     => file,
    owner      => "zulip",
    group      => "zulip",
    mode       => 600,
    source     => 'puppet:///modules/zulip/log2zulip.zuliprc',
  }
  file { "/etc/cron.d/check-apns-tokens":
    ensure => file,
    owner  => "root",
    group  => "root",
    mode => 644,
    source => "puppet:///modules/zulip/cron.d/check-apns-tokens",
  }
  file { "/etc/supervisor/conf.d/cron.conf":
    require => Package[supervisor],
    ensure => file,
    owner => "root",
    group => "root",
    mode => 644,
    source => "puppet:///modules/zulip/supervisor/conf.d/cron.conf",
  }
}
