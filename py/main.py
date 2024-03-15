from pyspark import SparkContext, SparkConf
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def main():
    # Configuration de Spark
    conf = SparkConf().setAppName("HelloWorld")
    conf.set("spark.eventLog.enabled", "true")

    # Initialisation du contexte Spark
    sc = SparkContext(conf=conf)

    # Logique de votre application Spark
    rdd = sc.parallelize(["Hello, World!"])    
    print(rdd.collect())

    # Arrêt du contexte Spark
    sc.stop()

@app.get("/hello")
def read_root():
    return {"Hello": "World"}

if __name__ == "__main__":
    main()