import redis
from os import getenv


def build_redis_url():
    host = getenv('REDIS_HOST', 'redis')
    port = getenv('REDIS_PORT', '6379')
    password = getenv('REDIS_PASSWORD') or ''
    db = getenv('REDIS_DB', '0')
    auth = f":{password}@" if password else ''
    return f"redis://{auth}{host}:{port}/{db}"


def init_redis(app=None):
    url = getenv('REDIS_URL') or build_redis_url()
    client = redis.Redis.from_url(url)
    if app:
        app.extensions['redis_client'] = client
    return client


def redis_healthcheck(client):
    try:
        return client.ping()
    except Exception:
        return False
