#!/bin/bash
#chmod +x script.sh 
# ./script.sh domain.name cpanel_username database_suffix 


#read -p 'Enter Dev website url without http or https: ' url
#read -p 'Enter a username for cpanel account: ' username
#read -p 'Enter a password for the account: ' password
#randpass=tr -cd "[:graph:]" < /dev/urandom | head -c 12 | xargs -0

# Create mySQL database
dbname=${2}"_"${3}
dbuser=${2}"_"${3}
dbpassword=$(tr -cd "[:graph:]" < /dev/urandom | head -c 12 | xargs -0)
echo -e "\nCreating mySQL database ($dbname) in new cPanel account"
uapi Mysql create_database name=$dbname
uapi Mysql create_user name=$dbuser password=$dbpassword
uapi Mysql set_privileges_on_database user=$dbuser database=$dbname privileges=ALL%20PRIVILEGES

# Create WordPress installation. 
echo "\n\nCreating WordPress dev website for $url"
wppass=$(openssl rand -base64 12)
echo $wppass
wp core download
wp config create --dbname=$dbname --dbuser=$dbuser --dbpass="$dbpassword" --dbprefix=${3}_
wp core install --url=${1} --title=devsetup --admin_user=admin --admin_password="$wppass" --admin_email=example@example.com
wp theme install twentynineteen --activate
wp search-replace "http://${1}" "https://${1}"

# Output all website Details. 
echo -e "\n========== WordPress Login Details ==============="
echo -e "Admin URL: https://${1}/wp-admin"
echo -e "username: admin"
echo -e "Password: $wppass"
echo -e "========== WordPress Login Details ===============\n"
