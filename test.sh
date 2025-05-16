PATTERN=" [%{http_code}] %{local_ip} %{url.path}"

ts() {
  printf $(date +"%T.%3N")' '
}

printf "Testing free resources\n========\n"
echo "http://localhost:80"
for count in {1..4};
do
    ts
    printf " $count "
    curl --ipv4 -w "${PATTERN} \n" http://localhost:80
    sleep .01s
done


printf "\nTesting unauthorized rate limits: max per POST endpoint+host 5/1d \n========\n"
echo "POST http://localhost:80/register_identity"
for count in {01..11};
do
    ts
    printf " $count "
    curl -XPOST -w "${PATTERN} \n" http://localhost:80/register_identity
    sleep .01s
done

printf "\nTesting unauthorized rate limits: max per GET endpoint+host 20/1d \n========\n"
echo "http://localhost:80/get_decryption_key"
for count in {01..21};
do
    ts
    printf " $count "
    curl -w "${PATTERN} \n" http://localhost:80/get_decryption_key
    sleep .01s
done

printf "\nTesting authorized rate limits: 1000/1d @get_data_for_encryption\n========\n"
KEY=$(cat caddy_data/apikeys.caddy|grep Bearer|tail -1|cut -d'"' -f2)
echo $KEY
for count in {0001..1001};
do
    ts
    printf " $count "
    curl -H "Authorization: ${KEY}" -w "${PATTERN} \n" http://localhost:80/get_data_for_encryption
    sleep .01s
done
