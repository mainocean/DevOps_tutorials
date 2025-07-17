#!/bin/sh
echo "Running collectstatic"
python manage.py collectstatic --noinput
exec "$@"
s