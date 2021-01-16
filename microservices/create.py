import os
import uuid
import json
import time
import utils
import boto3
dynamodb = boto3.resource('dynamodb')

def create(event, context):
    name_module = "client"
    data = json.loads(event['body'])
    required_values = {'firstName','lastName','birthday'}
    for value in required_values:
        if value not in data:
            response = utils.validate(value)
            return response

    timestamp = int(time.time())
    table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])
    response = table.scan()
    filter_result = response['Items']

    item = {
        'id': str(uuid.uuid1()),
        'firstName': data['firstName'],
        'lastName': data['lastName'],
        'birthday': data['birthday'],
        'create_at': timestamp,
        'updated_at': timestamp,
        'status': 1,
    }

    # write the todo to the database
    table.put_item(Item=item)

    # create a response
    response = utils.response(name_module, item, 'create')

    return response