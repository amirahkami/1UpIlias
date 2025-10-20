# ILIAS 10 Docker Container

This Docker setup provides a local development environment for IILAS Learn Management System.

### Quick Start

**run step 1, 2, 3 within your host machine**

1. Create a src directory for codebase as well as a .env file for enviroment variable
```bash
mkdir src
touch .env
cp example.env .env
# note: see also ilias.json and adjust database name, user, password corresponding as well
```

2. Clone ILIAS 10 into ./src
```bash
git clone https://github.com/ILIAS-eLearning/ILIAS.git ./src --single-branch -b release_10
```

3. Spin up containers
```bash
docker compose build --no-cache
docker compose up
```

**run following command once within container**

4. Install ILIAS (interactive)
```bash
cd /var/www/ilias && npm clean-install --omit=dev --ignore-scripts
cd /var/www/ilias && composer install --no-dev
cd /var/www/ilias && \
wget https://github.com/mathjax/MathJax/archive/3.2.2.tar.gz && \
   tar -xzf 3.2.2.tar.gz && \
   mkdir -p /var/www/ilias/libs/bower/bower_components && \
   mv MathJax-3.2.2 /var/www/ilias/libs/bower/bower_components/mathjax && \
   rm 3.2.2.tar.gz
cd /var/www/ilias && php cli/setup.php install /var/www/config/ilias.json
cd /var/www/files/ilias/myilias && mkdir temp
cd /var/www/ && chown -R www-data:www-data /var/www/files
```

5. head over to browser
   - visit http://localhost:8080

6. Login credentials:
   - Username: `root`
   - Password: `homer`
   
7. Change the password after first login.

That's it! Your ILIAS instance is ready to use.