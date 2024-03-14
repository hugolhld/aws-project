from pyspark import SparkContext, SparkConf
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def main():

    conf = SparkConf().setAppName("HelloWorld")
    sc = SparkContext(conf=conf)

    rdd = sc.parallelize(["Hello, World!"])    
    print(rdd.collect())

    sc.stop()

@app.get("/hello")
def read_root():
    return {"Hello": "World"}

if __name__ == "__main__":
    main()
