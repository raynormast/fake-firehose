docker compose -f docker-compose.yml down
docker build -t fakefirehose .
docker compose -f docker-compose.yml up 