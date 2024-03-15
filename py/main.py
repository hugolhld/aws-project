from pyspark import SparkContext, SparkConf
from fastapi import FastAPI
import boto3

app = FastAPI()

# Initialisez le client CloudWatch
cloudwatch = boto3.client('cloudwatch')

@app.get("/")
def main():
    # Configuration de Spark
    conf = SparkConf().setAppName("HelloWorld")
    conf.set("spark.eventLog.enabled", "true")
    conf.set("spark.eventLog.dir", "./monitoring")

    # Initialisation du contexte Spark
    sc = SparkContext(conf=conf)

    # Logique de votre application Spark
    rdd = sc.parallelize(["Hello, World!"])    
    print(rdd.collect())

    # Envoi d'une métrique à CloudWatch
    cloudwatch.put_metric_data(
        Namespace='VotreNamespace',
        MetricData=[
            {
                'MetricName': 'NombreDeTravauxSpark',
                'Value': 1,
                'Unit': 'Count'
            }
        ]
    )

    # Arrêt du contexte Spark
    sc.stop()

@app.get("/hello")
def read_root():
    return {"Hello": "World"}

if __name__ == "__main__":
    main()