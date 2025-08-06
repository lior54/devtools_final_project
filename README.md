# Devtools Final Project

This repository contains a Docker‑Compose environment that launches a fully working [Joomla](https://www.joomla.org/) site backed by a MySQL database. It also includes convenience scripts to build the environment, create administrator users, back up and restore the database, and clean up the containers when you are done.

The goal is to provide a reproducible, one‑command setup for local development, testing or demonstration of Joomla. With the provided scripts you can spin up the stack, create users, back up the data and tear everything down with minimal effort.

## Prerequisites

To run this project on your desktop you will need:

- **Docker** and **Docker Compose**. Make sure that both `docker` and `docker compose` commands are available in your path. The project relies on `docker compose up` to build and run the containers.
- **MySQL client tools** for backup/restore operations.  
  - The backup script uses `mysqldump` to create a database dump and will prompt you to install the `mysql-client-core` package if it isn’t available.  
  - The restore script checks for `mysqladmin`. On most Linux distributions these binaries are part of the same MySQL client package.
- A Unix‑like shell (Linux, macOS or Windows Subsystem for Linux). The scripts use `bash`.

## Repository contents
.
├── compose.yaml # Docker Compose definition for MySQL and Joomla
├── setup.sh # Builds and starts the containers and creates users
├── backup.sh # Dumps all MySQL databases into a compressed file
├── restore.sh # Downloads/restores the backup into MySQL
├── cleanup.sh # Tears down the containers, network and volumes
├── my-joomla.backup.sql.gz # Example database backup (compressed)
└── README.md # Project documentation (you are reading it)


### Services defined in `compose.yaml`

The Compose file defines two services:

- **db** – runs the latest MySQL image. The service is named `joomla_mysql`, uses `my-secret-pw` as the root password and creates a database called `my-db`. A named volume `db_data` is mounted at `/var/lib/mysql`. A health‑check runs `mysqladmin ping` to ensure the database is reachable.
- **joomla** – runs the latest Joomla image. It depends on the database service and waits until MySQL is healthy. The container is named `joomla_container` and exposes port 80 on the container as port 8080 on the host. It is configured via environment variables to connect to the database (`JOOMLA_DB_NAME=my-db`, `JOOMLA_DB_HOST=db`, etc.) and sets the initial site name and administrator credentials (`demoadmin` / `secretpassword`). A health‑check uses `curl` to check Joomla’s HTTP endpoint.

Both services attach to a custom bridge network called `joomla_network`. Feel free to change the environment variables or port mapping in `compose.yaml` to suit your needs. If you modify database credentials, be sure to update them consistently in both services.

## Quick start

1. **Clone** this repository:  

   git clone https://github.com/lior54/devtools_final_project.git
   cd devtools_final_project
Make the scripts executable (if necessary):

chmod +x setup.sh backup.sh restore.sh cleanup.sh
Bring up the environment:

./setup.sh
The script runs docker compose up --build -d, waits until Joomla reports a healthy status and then prints that the site is running at http://localhost:8080. It also creates two Joomla administrator accounts with username/password lior/securepass123 and yuval/securepass123 by invoking Joomla’s CLI. You can change or remove these lines if you prefer different accounts.

Access Joomla:
Open a browser and navigate to http://localhost:8080. Log in with the administrator credentials you specified in compose.yaml (demoadmin/secretpassword) or the accounts created in setup.sh.

View logs:
To follow container logs, run:

docker compose logs -f
Backing up the database
Use backup.sh to create a compressed dump of all databases. The script first checks that mysqldump is installed. It then uses docker exec to run mysqldump inside the joomla_mysql container and pipes the output through gzip to create my-joomla.backup.sql.gz. Run it like this:

./backup.sh
When the script finishes, the backup file will be in the project directory. You can adjust the name or location of the dump file in the script if desired.

Restoring the database
To restore from the compressed backup file (either the example provided in the repository or one you created), run restore.sh. This script verifies that mysqladmin is available, downloads the backup from GitHub if it isn’t present, decompresses it with gunzip and pipes it into the mysql client running inside the database container. After loading the data it restarts the Joomla container and waits until it becomes healthy.

./restore.sh
Restoring will overwrite existing data in the my-db database. If you changed the database name or credentials in compose.yaml, update the corresponding variables in restore.sh before running it.

Cleaning up
When you’re done with the environment, run cleanup.sh to stop and remove the containers, network, volumes and images. The script runs docker compose down --rmi all --volumes --remove-orphans, which removes everything created by the Compose stack. Use this command when you want to start fresh or reclaim disk space:


./cleanup.sh
Be careful—this will delete all data stored in the database volume.

Customizing the environment
Changing ports: Edit the ports section of the joomla service in compose.yaml if you want to expose Joomla on a different host port.

Changing database credentials: Update MYSQL_ROOT_PASSWORD, MYSQL_DATABASE, JOOMLA_DB_NAME, JOOMLA_DB_PASSWORD and related variables in compose.yaml. Ensure the values match between the two services.

Creating additional users: Use Joomla’s CLI inside the running container:

docker exec -it joomla_container php cli/joomla.php user:add \
  --username=youruser \
  --email=you@example.com \
  --password=yourpassword \
  --name="Your Name" \
  --usergroup=Administrator
The setup.sh script demonstrates how to use this command to create initial users.

Troubleshooting
If setup.sh hangs while waiting for Joomla to be healthy, run docker compose ps to see container statuses. Check the logs with docker compose logs for any errors.

Ensure that port 8080 is free on your machine or change it in compose.yaml.

On Windows, use WSL2 or Docker Desktop’s Linux containers mode to run the shell scripts.
