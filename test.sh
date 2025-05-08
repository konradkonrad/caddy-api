printf "Testing free resources\n========\n"
echo "http://localhost:8080"
for _ in {0..3};
do
    curl -w " %{http_code}\n" http://localhost:8080
    sleep .01s
done


printf "\nTesting unauthorized rate limits: max 2/1s 4/1m\n========\n"
echo "http://localhost:8080/api"
for _ in {0..10};
do
    curl -w " %{http_code}\n" http://localhost:8080/api
    sleep .4s
done

printf "\nTesting authorized rate limits: 10/1s @cheap resource\n========\n"
echo "-H 'Authorization: Bearer key1' http://localhost:8080/api"
for _ in {0..20};
do
    curl -H "Authorization: Bearer key1" -w " %{http_code}\n" http://localhost:8080/api
    sleep .05s
done

printf "\nTesting authorized rate limits: 1/1s @expensive resource\n========\n"
echo "-H 'Authorization: Bearer key1' http://localhost:8080/api/an_expensive_resource"
for _ in {0..20};
do
    curl -H "Authorization: Bearer key1" -w " %{http_code}\n" http://localhost:8080/api/an_expensive_resource
    sleep .05s
done
