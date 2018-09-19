# Serve static files
FROM httpd:2.4

COPY ./htdocs/ /usr/local/apache2/htdocs/

RUN ln -s /srv/jekyll/_site /usr/local/apache2/htdocs/info

EXPOSE 80/tcp