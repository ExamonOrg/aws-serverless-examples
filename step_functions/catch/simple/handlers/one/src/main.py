class MyException(Exception):
    pass


def lambda_handler(event: dict, context):
    raise MyException("This is an exception")
    return {"is_even": number % 2 == 0, "number": number};
