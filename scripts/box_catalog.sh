# Shared helpers for reading the self-hosted Vagrant box catalog
# (metadata.json). Meant to be sourced, not executed.

# fetch_catalog BOX_NAME DESCRIPTION URL
# Prints an empty catalog skeleton on 404/403 (missing key, unlistable bucket).
fetch_catalog() {
  local box_name="$1" description="$2" url="$3"
  local tmp_body
  tmp_body="$(mktemp)"
  local code
  code=$(curl --silent --show-error --output "$tmp_body" --write-out '%{http_code}' --url "$url")

  if [[ "$code" == "404" || "$code" == "403" ]]; then
    jq -n --arg name "$box_name" --arg desc "$description" '{name: $name, description: $desc, versions: []}'
  elif (( code >= 200 && code < 300 )); then
    cat "$tmp_body"
  else
    echo "::error::Fetching catalog failed (HTTP ${code})" >&2
    cat "$tmp_body" >&2
    rm -f "$tmp_body"
    exit 1
  fi
  rm -f "$tmp_body"
}

# provider_exists CATALOG_JSON VERSION PROVIDER ARCHITECTURE
# Prints "true"/"false".
provider_exists() {
  local catalog="$1" version="$2" provider="$3" arch="$4"
  jq --arg version "$version" --arg provider "$provider" --arg arch "$arch" \
    'any(.versions[]?; .version == $version and any(.providers[]?; .name == $provider and .architecture == $arch))' \
    <<< "$catalog"
}

# merge_provider CATALOG_JSON VERSION PROVIDER_JSON
# Appends PROVIDER_JSON into the matching version's providers array, or
# a new version object if VERSION doesn't exist yet. Run sequentially,
# not in parallel, if multiple providers ever release in one run.
merge_provider() {
  local catalog="$1" version="$2" provider_json="$3"
  jq --arg version "$version" --argjson provider "$provider_json" \
    'if any(.versions[]?; .version == $version) then
       (.versions[] | select(.version == $version) | .providers) += [$provider]
     else
       .versions += [{version: $version, status: "active", providers: [$provider]}]
     end' \
    <<< "$catalog"
}
