import json
import datetime
import decimal
from math import sqrt

access_control = {'Access-Control-Allow-Origin': '*','Access-Control-Allow-Credentials': 'true'}

def validate(value):

	body = {'status': False, 'message': value + " is required."}
	response = {
		"statusCode": 400,
		"headers": access_control,
		"body": json.dumps(body)
	}
	return response

def response(module, item, action):

	response_data = {
		"success": True,
		"message": module + " " + action + " successfully.",
		"data": item
	}

	response = {
		"statusCode": 200,
		"headers": access_control,
		"body": json.dumps(response_data, default=decimal_default)
	}

	return response

def calculateAge(birthDate): 
    today = datetime.date.today() 
    age = today.year - birthDate.year - ((today.month, today.day) < (birthDate.month, birthDate.day)) 
  
    return age 


def standardDeviation(values, media):
	ssum = 0
	for val in values:
		ssum += (val - media) ** 2

	residing = ssum / (len(values) - 1)

	return sqrt(residing)

def decimal_default(obj):
    if isinstance(obj, decimal.Decimal):
        return int(obj)
    raise TypeError