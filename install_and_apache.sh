#!/bin/bash
# create a sudo user to install arches under e.g 'archesadmin'
project_name="project"
username="archesadmin"

sudo su

apt update
apt install software-properties-common
add-apt-repository ppa:deadsnakes/ppa
apt install python3.8
apt-get -y install python3.8-venv python3.8-dev

git clone https://github.com/archesproject/arches.git

python3.8 -m venv env
source env/bin/activate

#setup arches
cd arches
git checkout origin/stable/5.2.x
yes | bash arches/install/ubuntu_setup.sh

pip install wheel
pip install -e .
pip install -r arches/install/requirements.txt

yarn

arches-project create $project_name
cd $project_name
python manage.py setup_db

apt-get install apache2
apt install apache2-dev python3-dev
pip install mod_wsgi

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

a2dissite 000-default
a2ensite arches-default
service apache2 reload

mkdir -p /home/$username/$project_name/$project_name/static/

chmod 664 /home/$username/$project_name/$project_name/arches.log
chgrp www-data /home/$username/$project_name/$project_name/arches.log

chmod 775 /home/$username/$project_name/$project_name/uploadedfiles
chgrp www-data /home/$username/$project_name/$project_name/uploadedfiles

chmod 775 /home/$username/$project_name/$project_name
chgrp www-data /home/$username/$project_name/$project_name

chmod 775 /home/$username/$project_name/$project_name/static
chgrp www-data /home/$username/$project_name/$project_name/static


static_vars="STATIC_ROOT = os.path.join(APP_ROOT, 'static')
STATIC_URL = '/static/'
"

static_vars >> /home/$username/$project_name/$project_name/settings.py

cd /home/$username/$project_name/
python manage.py collectstatic -yes

service apache2 restart