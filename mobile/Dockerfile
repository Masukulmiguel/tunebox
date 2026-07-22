FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ffmpeg \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp \
    && chmod +x /usr/local/bin/yt-dlp

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY music_server.py .

EXPOSE 9090

CMD ["python", "music_server.py"]
