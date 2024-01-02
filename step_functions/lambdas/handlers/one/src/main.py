import random

def lambda_handler(event: dict, context):
    upper_limit = 1000
    lower_limit = 0
    number = random.randint(lower_limit, upper_limit)
    return {"is_even": number % 2 == 0, "number": number};
