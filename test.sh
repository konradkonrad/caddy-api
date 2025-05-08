for _ in {0..10};
do
    curl -w "%{http_code}\n" http://localhost:8080
    sleep .1s
done


for _ in {0..20};
do
    curl -w "%{http_code}\n" http://localhost:8080/api
    sleep .4s
done
