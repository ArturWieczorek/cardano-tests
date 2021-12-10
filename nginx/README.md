# Nginx config to redirect HTTP to HTTPS

Add this to your `/etc/nginx/nginx.conf` :


```sh
http {

server {
    listen 80;

    server_name smash-server.com;

    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;

    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

    server_name smash-server.com;

    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
	proxy_pass  http://127.0.0.1:3100;
        try_files $uri $uri/ /index.html =404;
    }
}
```


and add this to your `/etc/hosts` file:

```sh
cat /etc/hosts
127.0.0.1	localhost
127.0.0.1	smash-server.com
```

This way you can access `smash-server.com` in your browser and it will be using HTTPS.
You need to have proper certificate in order to padlock not being displayed in red as untrusted.
You can use https://certbot.eff.org/ or other services for that.


