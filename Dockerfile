# Use the official lightweight Python image.
# https://hub.docker.com/_/python
FROM python:3.9-slim AS base

# Create and change to the app directory
WORKDIR /app

# Copy local files into Docker image
COPY requirements.txt /app/requirements.txt
COPY main.py /app/main.py

# Install all requirements.  Use --no-cache-dir
# to ensure the Docker image is as small as possible.
RUN pip install --no-cache-dir -r /app/requirements.txt

#############################################
# Development container from the common base
FROM base AS development


#############################################
# Testing container from the common base
FROM base AS testing

# Define the webserver port
ENV PORT=${PORT:-8080}

# Run the gunicorn webserver
CMD exec gunicorn --bind :$PORT --timeout 0 main:app


#############################################
# Production container from the common base
FROM base AS production

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Run the gunicorn webserver, with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app
