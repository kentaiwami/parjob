import inspect
from flask import Blueprint, jsonify, request, abort
from jsonschema import validate, ValidationError
from model import User
from database import session
from views.v1.response import response_msg_200
from basic_auth import api_basic_auth

app = Blueprint('token_bp', __name__)


@app.route('/api/v1/token', methods=['PUT'])
@api_basic_auth.login_required
def update_token():
    schema = {'type': 'object',
              'properties':
                  {'token': {'type': 'string', 'minimum': 1}
                   },
              'required': ['token']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})

    user = session.query(User).filter(User.code == api_basic_auth.username()).one()
    user.token = request.json['token']

    session.commit()
    session.close()

    return jsonify({'msg': response_msg_200()}), 200
