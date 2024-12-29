import boto3
import re

s3 = boto3.client('s3')
sns = boto3.client('sns')

def lambda_handler(event, context):
    # Odczytaj szczegóły zdarzenia
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    file_name = event['Records'][0]['s3']['object']['key']
    
    try:
        # Pobierz plik z S3
        response = s3.get_object(Bucket=bucket_name, Key=file_name)
        file_content = response['Body'].read().decode('utf-8')
        
        # Przetwórz zawartość pliku
        alert_triggered = False
        
        try:
            for line in file_content.splitlines():
                replaced = re.sub(r'\s+', '', line.strip())
                value = int(replaced[:4])
                if value <= 2000:
                    alert_triggered = True
                    break
        except Exception as e:
            print(e)

        if alert_triggered:
            message = {
                "Message": f"Cena PS5 spadła poniżej 2000! Aktualna cena: {value}",
                "Subject": "Alert - Kwota poniżej 2000",
                "TopicArn": "arn:aws:sns:eu-central-1:872515283157:price-alerts"
            }
            sns.publish(**message)
            print('E-mail wysłany!')
        else:
            print('Brak kwot poniżej 2000 w pliku.')

    except Exception as e:
        print(f"Error: {str(e)}")
        raise e
