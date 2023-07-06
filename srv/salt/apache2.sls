repo-configure-base:
  pkgrepo.managed:
    - file: /etc/apt/sources.list
    - name: deb http://dl.astralinux.ru/astra/frozen/1.7_x86-64/1.7.3/repository-base/          1.7_x86-64 main contrib non-free
    - clean_file: true
    - refresh: false

repo-configure-ext:
  pkgrepo.managed:
    - file: /etc/apt/sources.list
    - name: deb http://dl.astralinux.ru/astra/frozen/1.7_x86-64/1.7.3/repository-extended/      1.7_x86-64 main contrib non-free
    - refresh: false

repo-configure-uu1:
  pkgrepo.managed:
    - file: /etc/apt/sources.list
    - name: deb http://dl.astralinux.ru/astra/frozen/1.7_x86-64/1.7.3/uu/1/repository-base/     1.7_x86-64 main contrib non-free
    - refresh: true

apache2-install-pkg:
  pkg.installed:
    - name: apache2

apache2-start-service:
  service.running:
    - name: apache2
    - enable: true
    - require:
      - pkg: apache2

apache2-turn-off-keepalie:
  file.replace:
    - name: /etc/apache2/apache2.conf
    - pattern: 'KeepAlive On'
    - repl: 'KeepAlive Off'
    - show_changes: true
    - require:
      - pkg: apache2

apache2-disable-astramod:
  file.append:
    - name: /etc/apache2/apache2.conf 
    - text: 
      - "AstraMode off"

apache2-push-tune-conf:
  file.managed:
    - name: /etc/apache2/conf-available/tune_apache.conf
    - source: salt://files/tune_apache.conf
    - require:
      - pkg: apache2

apache2-enable-tune-conf:
  apache_conf.enabled:
    - name: tune_apache
    - require:
      - pkg: apache2

/var/www/html/{{ pillar['domain'] }}:
  file.directory

/var/www/html/{{ pillar['domain'] }}/log:
  file.directory

/var/www/html/{{ pillar['domain'] }}/backups:
  file.directory

/var/www/html/{{ pillar['domain'] }}/public_html:
  file.directory

apache2-disable-default-site:
  apache_site.disabled:
    - name: 000-default
    - require:
      - pkg: apache2

apache2-configure-httpd-conf:
  apache.configfile:
    - name: /etc/apache2/sites-available/{{ pillar['domain'] }}.conf
    - config:
      - VirtualHost:
          this: '*:80'
          ServerName:
            - {{ pillar['domain'] }}
          ServerAlias:
            - www.{{ pillar['domain'] }}
          DocumentRoot: /var/www/html/{{ pillar['domain'] }}/public_html
          ErrorLog: /var/www/html/{{ pillar['domain'] }}/log/error.log
          CustomLog: /var/www/html/{{ pillar['domain'] }}/log/access.log combined

apache2-enable-configured-site:
  apache_site.enabled:
    - name: {{ pillar['domain'] }}
    - require:
      - pkg: apache2

apache2-push-default-html:
  file.managed:
    - name: /var/www/html/{{ pillar['domain'] }}/public_html/index.html
    - source: salt://{{ pillar['domain'] }}/index.html
 
apache2-service:
  service.running:
    - name: apache2
    - reload: true
    - watch:
      - apache2-configure-httpd-conf
      - apache2-enable-configured-site
      - apache2-turn-off-keepalie
      - apache2-disable-astramod
      - apache2-enable-tune-conf
      - apache2-push-tune-conf

