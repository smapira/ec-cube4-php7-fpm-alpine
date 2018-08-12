# ec-cube4-php7-fpm-alpine

## usage
```bash
docker build --rm -t smapira/ec-cube4-php7-fpm-alpine .
NAME_SPACE=ec-cube
docker run \
	-d \
	-p 80:8000 \
    --name ${NAME_SPACE} \
    smapira/ec-cube4-php7-fpm-alpine
open http://localhost
```
