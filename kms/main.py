import boto3

region_name = 'eu-west-1'


class KMSHandler:
    def __init__(self, kms_arn):
        self.kms_arn = kms_arn
        self.kms_client = boto3.client('kms', region_name=region_name)

    def encrypt_text(self, plaintext):
        response = self.kms_client.encrypt(
            KeyId=self.kms_arn,
            Plaintext=plaintext
        )
        return response['CiphertextBlob']

    def decrypt_text(self, ciphertext):
        response = self.kms_client.decrypt(
            CiphertextBlob=ciphertext
        )
        return response['Plaintext']


def main():
    kms_arn = 'arn:aws:kms:eu-west-1:478119378221:key/0ecb8801-2da7-4a5c-9c11-61637daa25b7'
    kms_handler = KMSHandler(kms_arn)

    option = input("Enter 'e' to encrypt or 'd' to decrypt: ")

    if option == 'e':
        plaintext = input("Enter the text to encrypt: ")
        ciphertext = kms_handler.encrypt_text(plaintext)
        with open('encrypted.txt', 'wb') as file:
            file.write(ciphertext)
        print("Encrypted text written to 'encrypted.txt'")
    elif option == 'd':
        with open('encrypted.txt', 'rb') as file:
            ciphertext = file.read()
        plaintext = kms_handler.decrypt_text(ciphertext)
        plaintext = plaintext.decode()  # Convert bytes to string
        print(plaintext)
    else:
        print("Invalid option. Please try again.")


if __name__ == '__main__':
    main()
