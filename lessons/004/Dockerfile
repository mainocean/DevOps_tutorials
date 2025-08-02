FROM python:3.12.2-slim-bullseye

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENV PORT=8080
EXPOSE $PORT

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["gunicorn", "django_ec2_complete.wsgi:application", "--bind", "0.0.0.0:8080"]

