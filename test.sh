PATTERN=" [%{http_code}] %{local_ip} %{url.path}"

ts() {
  printf $(date +"%T.%3N")' '
}

printf "Testing free resources\n========\n"
echo "http://localhost:8080"
for _ in {0..3};
do
    ts
    curl --ipv4 -w "${PATTERN} \n" http://localhost:8080
    sleep .01s
done


printf "\nTesting unauthorized rate limits: max per host 2/1s 4/10s global 10/1m\n========\n"
echo "http://localhost:8080/api"
for _ in {0..20};
do
    ts
    curl -w "${PATTERN} \n" http://localhost:8080/api
    sleep .4s
done

printf "\nTesting unauthorized global rate limits:\n========\n"
echo "http://localhost:8080/api (different host every time)"
for _ in {0..6};
do
    ts
    docker run --rm -it --network testcaddy curlimages/curl -w "${PATTERN} \n" http://testcaddy:8080/api
    sleep .4s
done

printf "\nTesting authorized rate limits: 10/1s @cheap resource\n========\n"
for _ in {0..20};
do
    ts
    curl -H "Authorization: Bearer key1" -w "${PATTERN} \n" http://localhost:8080/api
    sleep .05s
done

printf "\nTesting authorized rate limits: 1/1s @expensive resource\n========\n"
for _ in {0..20};
do
    ts
    curl -H "Authorization: Bearer key1" -w "${PATTERN} key1 \n" http://localhost:8080/api/an_expensive_resource
    ts
    curl -H "Authorization: Bearer key2" -w "${PATTERN} key2 \n" http://localhost:8080/api/an_expensive_resource
    sleep .05s
done
