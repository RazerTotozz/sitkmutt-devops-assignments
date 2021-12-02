docker build ../ratings/ -t ratings

docker build ../details/ -t details

docker build ../reviews/ -t reviews

docker build ../productpage/ -t productpage

docker run -d --name mongodb -p 27017:27017 \
  -v $(pwd)/databases:/docker-entrypoint-initdb.d bitnami/mongodb:5.0.2-debian-10-r2

docker run ratings -d -p 8080:8080 --name ratings -e SERVICE_VERSION=v2 -e 'MONGO_DB_URL=mongodb://mongodb:27017/ratings'

docker run details -d -p 8081:8081 --name details

docker run reviews -d -p 8082:9080 --name reviews --link ratings:ratings -e 'ENABLE_RATINGS=true' -e 'STAR_COLOR=yellow' -e 'RATINGS_SERVICE=http://ratings:8080'

docker run productpage -d -p 8083:8083 --name productpage --link ratings:ratings --link reviews:reviews --link details:details \
-e 'DETAILS_HOSTNAME=http://details:8081' -e 'RATINGS_HOSTNAME=http://ratings:8080' -e 'REVIEWS_HOSTNAME=http://reviews:9080' -e 'FLOOD_FACTOR=1'