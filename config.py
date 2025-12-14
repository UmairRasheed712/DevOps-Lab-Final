from os import environ, getenv, path
import logging

# Ensure FLASK_ENV is always set so tests accessing environ['FLASK_ENV'] do not raise
environ.setdefault('FLASK_ENV', 'test')


def get_database_uri(test=False):
    # Build host and optional port; only append port when explicitly provided
    host = getenv('POSTGRES_HOST_TEST', 'db') if test else getenv('POSTGRES_HOST', 'db')
    port = getenv('POSTGRES_PORT_TEST') if test else getenv('POSTGRES_PORT')
    if port:
        host = f"{host}:{port}"

    POSTGRES = {
        'user': getenv('POSTGRES_USER_TEST', 'postgres') if test else getenv('POSTGRES_USER', 'postgres'),
        'pw': getenv('POSTGRES_PASSWORD_TEST', 'docker') if test else getenv('POSTGRES_PASSWORD', 'docker'),
        'db': getenv('POSTGRES_DB_TEST', 'pfaas_test') if test else getenv('POSTGRES_DB', 'pfaas_dev'),
        'host': host,
    }
    return 'postgresql://%(user)s:%(pw)s@%(host)s/%(db)s' % POSTGRES


BASE_PATH = path.dirname(path.abspath(__file__))


class Config(object):
    LOG_APP_NAME = getenv('LOG_APP_NAME') or 'api'
    LOG_COPIES = 10
    LOG_DIR = path.join(BASE_PATH, '.logs', 'development')
    LOG_FILE = path.join(LOG_DIR, 'server.log')
    LOG_INTERVAL = 1
    LOG_LEVEL = getenv('LOG_LEVEL') or logging.DEBUG
    LOG_TIME_INT = 'D'
    LOG_TYPE = getenv('LOG_TYPE') or 'TimedRotatingFile'
    LOG_WWW_NAME = getenv('LOG_WWW_NAME') or 'api-access'
    PROFILE = True
    PROFILE_PATH = path.join(BASE_PATH, '.profiles')
    SECRET_KEY = getenv('SECRET_KEY') or 'some_real_good_secret'
    SQLALCHEMY_DATABASE_URI = get_database_uri()
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {'pool_pre_ping': True}
    SQLALCHEMY_ECHO = True


class TestConfig(Config):
    LOG_DIR = path.join(
        BASE_PATH, '.logs', 'test',
        getenv('FLASK_ENV', 'test') if getenv('FLASK_ENV', 'test') != 'test' else ''
    )
    LOG_LEVEL = getenv('LOG_LEVEL') or logging.INFO
    PROFILE = False
    SQLALCHEMY_ECHO = False
    SQLALCHEMY_DATABASE_URI = get_database_uri(test=True)
    TESTING = True


class ProdConfig(Config):
    LOG_DIR = path.join(BASE_PATH, '.logs', 'production')
    LOG_LEVEL = getenv('LOG_LEVEL') or logging.WARN
    LOG_TYPE = 'stream'
    PROFILE = False
    SECRET_KEY = getenv('SECRET_KEY')
    SQLALCHEMY_ECHO = False


class StagingConfig(ProdConfig):
    LOG_DIR = path.join(BASE_PATH, '.logs', 'staging')
    LOG_LEVEL = getenv('LOG_LEVEL') or logging.INFO


def get_config(test=False):
    FLASK_ENV = getenv('FLASK_ENV', 'production')
    if (test or FLASK_ENV == 'test'):
        return TestConfig
    if FLASK_ENV == 'development':
        return Config
    elif FLASK_ENV == 'staging':
        return StagingConfig
    else:
        return ProdConfig
