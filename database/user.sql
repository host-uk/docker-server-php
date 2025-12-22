-- schema.sql (or a separate file, e.g. grants.sql)

-- Make sure the DB exists first (the official entrypoint creates it from MYSQL_DATABASE)
CREATE DATABASE IF NOT EXISTS `${DB_NAME}`;

-- Create the user if it does not exist and allow connections from any host
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

-- Grant the desired privileges (adjust as needed)
GRANT ALL PRIVILEGES ON `${DB_NAME}`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;