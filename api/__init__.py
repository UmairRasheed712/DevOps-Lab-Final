import logging
from datetime import datetime as dt
from flask import Flask, request
from flask_cors import CORS
from config import get_config
from .extensions import db, logs, migrate
from .cache import init_redis


def create_app(test=False):
    config = get_config(test=test)
    app = Flask(__name__)
    app.config.from_object(config)
    
    # Enable CORS for frontend to access API
    CORS(app, resources={r"/api/*": {"origins": "*"}, r"/graphiql": {"origins": "*"}})

    register_extensions(app)
    init_redis(app)

    # Blueprint registration here.
    from .main import bp as main_bp
    app.register_blueprint(main_bp)

    @app.after_request
    def after_request(response):
        if request.method != 'POST':
            return response
        """ Logging after every POST request only if it isn't an introspection query. """
        json_data = request.get_json()
        is_introspection_query = bool(json_data and json_data.get(
            'operationName', False) == 'IntrospectionQuery')
        if not is_introspection_query:
            logger = logging.getLogger('api.access')
            logger.info(
                '%s [%s] %s %s %s %s %s %s %s',
                request.remote_addr,
                dt.utcnow().strftime('%d/%b/%Y:%H:%M:%S.%f')[:-3],
                request.method,
                request.path,
                request.scheme,
                response.status,
                response.content_length,
                request.referrer,
                request.user_agent,
            )
        return response

    @ app.teardown_appcontext
    def shutdown_session(exception=None):
        db.session.remove()

    return app


def register_extensions(app):
    db.init_app(app)
    logs.init_app(app)
    migrate.init_app(app, db)
    
    # Import models after db is initialized to avoid circular imports
    from api import db_models
    
    return None
