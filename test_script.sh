#!/bin/bash
project_name="project"
username="archesadmin"
arches_version="origin/stable/5.2.x"
conf="# If you have mod_wsgi installed in your python virtual environment, paste the text generated
# by 'mod_wsgi-express module-config' here, *before* the VirtualHost is defined.

<VirtualHost *:80>

    WSGIDaemonProcess arches python-path=/home/$username/$project_name
    WSGIScriptAlias / /home/$username/$project_name/$project_name/wsgi.py process-group=arches

    LoadModule wsgi_module "/home/$username/$project_name/env/lib/python3.8/site-packages/mod_wsgi/server/mod_wsgi-py38.cpython-38-x86_64-linux-gnu.so"
    WSGIPythonHome "/home/$username/$project_name/env"


    # Necessary to support Arches Collector
    WSGIPassAuthorization on

    ## Uncomment the ServerName directive and fill it with your domain
    ## or subdomain if/when you have your DNS records configured.
    # ServerName heritage-inventory.org

    <Directory /home/$username/$project_name>
        Require all granted
    </Directory>

    # This section tells Apache where to find static files. This example uses
    # STATIC_URL = '/media/' and STATIC_ROOT = os.path.join(APP_ROOT, 'static')
    # NOTE: omit this section if you are using S3 to serve static files.
    Alias /static/ /home/$username/$project_name/$project_name/static/
    <Directory /home/$username/$project_name/$project_name/static/>
        Require all granted
    </Directory>

    # This section tells Apache where to find uploaded files. This example uses
    # MEDIA_URL = '/files/' and MEDIA_ROOT = os.path.join(APP_ROOT)
    # NOTE: omit this section if you are using S3 for uploaded media
    Alias /files/uploadedfiles/ /home/$username/$project_name/$project_name/uploadedfiles/
    <Directory /home/$username/$project_name/$project_name/uploadedfiles/>
        Require all granted
    </Directory>

    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
    # error, crit, alert, emerg.
    # It is also possible to configure the loglevel for particular
    # modules, e.g.
    #LogLevel info ssl:warn
    # Recommend changing these file names if you have multiple arches
    # installations on the same server.
    ErrorLog /var/log/apache2/error-arches.log
    CustomLog /var/log/apache2/access-arches.log combined

</VirtualHost>"

conf > /etc/apache2/sites-available/000-default.conf