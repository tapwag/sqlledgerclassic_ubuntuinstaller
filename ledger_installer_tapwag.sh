#!/bin/bash
#=====================================================================
# Internatioinal SQL-Ledger-Network Association
# Copyright (c) 2014-2016
#
#  Author: Maik Wagner
#     Web: http://www.linuxandlanguages.com
#   Email: maiktapwagner@aol.com
#
#  Based on the ledger123 Installation Script by Sebastian Weitmann
#  Edit: 4 February 2016: This script now pulls my tapwag/sql-ledger
#  repostory instead of Tekki's. 
# 
#======================================================================
#
# Installation Script for SQL-Ledger standard Version 3.2 version
# for Ubuntu 14.04.3 (Trusty Tahr) 
#
#======================================================================
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details:
# <http://www.gnu.org/licenses/>.
#======================================================================
#
# This script calls the installation function.
#

# Hauptinstallationsroutine / Main installation routine

installation ()
{

clear 
echo "Updating and installing dependencies..."

cd ~/  
apt-get -y install debian-archive-keyring
add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
apt-key update 
apt-get update 
apt-get upgrade 
apt-get -y install git acpid apache2 postgresql libdbi-perl libdbd-pg-perl git-core gitweb postfix mailutils texlive texlive-lang-german
a2ensite default-ssl
service apache2 reload
a2enmod ssl
a2enmod cgi
service apache2 restart
cd /usr/local
git clone git://github.com/tapwag/sql-ledger.git
cd /usr/local/sql-ledger
git checkout -b full origin/full
mkdir spool
chown -hR www-data.www-data users templates css spool
cp sql-ledger.conf.default sql-ledger.conf
cd ~/
cp sql-ledger /etc/apache2/sites-available/
cd /etc/apache2/sites-enabled/
ln -s ../sites-available/sql-ledger 001-sql-ledger

echo "AddHandler cgi-script .pl" >> /etc/apache2/apache2.conf
echo "Alias /sql-ledger /usr/local/sql-ledger" >> /etc/apache2/apache2.conf
echo "<Directory /usr/local/sql-ledger>" >> /etc/apache2/apache2.conf
echo "Options ExecCGI Includes FollowSymlinks" >> /etc/apache2/apache2.conf
echo "</Directory>" >> /etc/apache2/apache2.conf
echo "<Directory /usr/local/sql-ledger/users>" >> /etc/apache2/apache2.conf
echo "Order Deny,Allow" >> /etc/apache2/apache2.conf
echo "Deny from All" >> /etc/apache2/apache2.conf
echo "</Directory>" >> /etc/apache2/apache2.conf


service apache2 restart
cd ~/

# Postgres Installation 
clear
echo "Initialising Postgres - Press RETURN to continue"
read confirmation
locale-gen de_DE.UTF-8
pg_createcluster --locale=de_DE.UTF-8 --encoding=UTF-8 9.3 main --start

wget http://www.sql-ledger-network.com/debian/pg_hba.conf --retr-symlinks=no
cp pg_hba.conf /etc/postgresql/9.3/main/
service postgresql restart
su postgres -c "createuser -d -S -R sql-ledger"

}


# Main program

clear
echo "Copyright (C) 2015  International SQL-Ledger Network Associaton"
echo "This is free software, and you are welcome to redistribute it under"
echo "certain conditions; See <http://www.gnu.org/licenses/> for more details"
echo "This program comes with ABSOLUTELY NO WARRANTY"
echo "PLEASE NOTE:"
echo "This script will make some fairly major changes to your Ubuntu system:"
echo "- Adding universe repository"
echo "- Modifying the main apache2.conf file to handle the SQL Ledger directory which will be in the default document root: /var/www/html"
echo "If you agree to these changes to your Ubuntu system please type 'installation'. Any other input will back you out and return to the command line."
read input
	
if [ "$input" = "installation" ]; then
		installation 
	     	clear
		echo 
		echo "Thank you for your patience! The automatic installation has now been completed."
		echo
		echo "You should now be able to login to the latest SQL-Ledger Classic version (sql-ledger) as 'admin' on http://yourserver_ip/sql-ledger"		echo 
		echo "Visit http://www.sql-ledger-network.com for more information on SQL-Ledger"
		echo "Visit http://forum.sql-ledger-network.com for support"
		echo "Suggestions for improvement and other feedback can be emailed to 'info@sql-ledger-network.com'. Thanks!"
		echo
		echo "IMPORTANT NOTE: This simple installation was designed to be run only on the local network."
fi
exit 0
