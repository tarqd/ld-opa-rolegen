opa eval -b . --format=values 'data.minigen.role_policy' | jq -rc '.[] | to_entries[] | [.key, .value] | .[]' | while read -L name value; echo "$value" | jq . > "out/$name.json"; end 
