printf "Testing free resources\n========\n"
echo "http://localhost:8080"
for _ in {0..3};
do
    curl -w " %{http_code}\n" http://localhost:8080
    sleep .01s
done


printf "\nTesting unauthorized rate limits: max per host 2/1s 4/10s global 10/1m\n========\n"
echo "http://localhost:8080/api"
for _ in {0..20};
do
    curl -w " %{http_code}\n" http://localhost:8080/api
    sleep .4s
done

printf "\nTesting unauthorized global rate limits:\n========\n"
echo "http://localhost:8080/api (different host every time)"
for _ in {0..6};
do
    docker run --rm -it --network testcaddy curlimages/curl -w " %{http_code}\n" http://testcaddy:8080/api
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
