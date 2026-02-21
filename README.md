# php-laravel-octane-swoole
A base container to use in a php laravel octane project with swoole

## Instructions to publish
1. Run the command to build a image

```bash
docker build -t php-laravel-octane-swoole .
```

2. Run the command to create a tag
```bash
docker tag php-laravel-octane-swoole your-docker-user/php-laravel-octane-swoole:1.0.0
```

3. Run the command to login in docker (if not yet)
```bash
docker login
```

4. Run he command to publish de image
```bash
docker push your-docker-user/php-laravel-octane-swoole:1.0.0
```